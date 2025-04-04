resource "aws_ecs_cluster" "cloud_platforms" {
  name = format(local.resource_name, var.ecs_cluster_config.name)

  tags = {
    Name = format(local.resource_name, var.ecs_cluster_config.name)
  }
}

resource "aws_ecs_task_definition" "webapi" {
  family                   = format(local.resource_name, var.ecs_cluster_config.task_definitions.webapi.family)
  network_mode             = var.ecs_cluster_config.task_definitions.webapi.network_mode
  requires_compatibilities = var.ecs_cluster_config.task_definitions.webapi.requires_compatibilities
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile(("${path.module}/templates/container_definitions/webapi.json.tftpl"),
    {
      container_name     = var.ecs_cluster_config.task_definitions.webapi.container.name
      container_port     = var.ecs_cluster_config.task_definitions.webapi.container.port
      container_cpu      = var.ecs_cluster_config.task_definitions.webapi.container.cpu
      container_memory   = var.ecs_cluster_config.task_definitions.webapi.container.memory
      webapi_image       = format("%s:%s", var.ecr_repository_uri, var.api_image_tag)
      aspnet_environment = var.ecs_cluster_config.task_definitions.webapi.aspnetcore_env.ASPNETCORE_ENVIRONMENT
      aspnet_urls        = var.ecs_cluster_config.task_definitions.webapi.aspnetcore_env.ASPNETCORE_URLS
    }
  )

  tags = {
    Name = format(local.resource_name, var.ecs_cluster_config.task_definitions.webapi.family)
  }
}

resource "aws_ecs_service" "webapi" {
  name                               = format(local.resource_name, var.ecs_cluster_config.services.webapi.name)
  cluster                            = aws_ecs_cluster.cloud_platforms.id
  task_definition                    = aws_ecs_task_definition.webapi.arn
  desired_count                      = var.ecs_cluster_config.services.webapi.desired_count
  deployment_minimum_healthy_percent = var.ecs_cluster_config.services.webapi.deployment.min_percent
  deployment_maximum_percent         = var.ecs_cluster_config.services.webapi.deployment.max_percent

  load_balancer {
    target_group_arn = aws_lb_target_group.webapi.arn
    container_name   = var.ecs_cluster_config.task_definitions.webapi.container.name
    container_port   = var.ecs_cluster_config.task_definitions.webapi.container.port
  }

  lifecycle {
    ignore_changes = [
      task_definition,
    ]
  }
  tags = {
    Name = format(local.resource_name, var.ecs_cluster_config.services.webapi.name)
  }
}