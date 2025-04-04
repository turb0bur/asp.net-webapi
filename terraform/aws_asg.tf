resource "aws_launch_template" "webapi" {
  name_prefix   = join("-", [var.application_name, var.webapi_instances_config.template_prefix_name])
  image_id      = data.aws_ami.amazon_linux_ecs.image_id
  instance_type = var.webapi_instances_config.instance_type

  block_device_mappings {
    device_name = var.webapi_instances_config.root_volume_name
    ebs {
      volume_size           = var.webapi_instances_config.ebs_volume.size
      volume_type           = var.webapi_instances_config.ebs_volume.type
      delete_on_termination = var.webapi_instances_config.ebs_volume.delete_on_termination
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.application_profile.name
  }

  metadata_options {
    http_tokens = "required"
  }

  network_interfaces {
    security_groups = [aws_security_group.webapi_sg.id]
  }

  user_data = base64encode(
    templatefile(("${path.module}/templates/user_data/app_user_data.sh.tftpl"),
      {
        ECS_CLUSTER_NAME = aws_ecs_cluster.cloud_platforms.name
      }
    )
  )
}

resource "aws_autoscaling_group" "webapi_asg" {
  name                = format(local.resource_name, var.webapi_asg_config.name)
  desired_capacity    = var.webapi_asg_config.desired_capacity
  max_size            = var.webapi_asg_config.max_size
  min_size            = var.webapi_asg_config.min_size
  vpc_zone_identifier = [for subnet in aws_subnet.application : subnet.id]
  launch_template {
    id      = aws_launch_template.webapi.id
    version = var.webapi_asg_config.launch_template_version
  }
  health_check_type         = var.webapi_asg_config.health_check_type
  health_check_grace_period = var.webapi_asg_config.health_check_grace_period

  dynamic "tag" {
    for_each = local.webapi_asg_ec2_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
