resource "aws_launch_template" "nat" {
  name_prefix   = join("-", [var.application_name, var.nat_instances_config.template_prefix_name])
  image_id      = data.aws_ami.amazon_linux_nat.image_id
  instance_type = var.nat_instances_config.instance_type

  block_device_mappings {
    device_name = var.nat_instances_config.root_volume_name
    ebs {
      volume_size           = var.nat_instances_config.ebs_volume.size
      volume_type           = var.nat_instances_config.ebs_volume.type
      delete_on_termination = var.nat_instances_config.ebs_volume.delete_on_termination
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.nat_profile.name
  }

  metadata_options {
    http_tokens = "required"
  }

  network_interfaces {
    security_groups = [aws_security_group.nat_sg.id]
  }

  user_data = base64encode(
    templatefile(("${path.module}/templates/user_data/nat_user_data.sh.tftpl"),
      {
        REGION                 = var.region
        PRIVATE_ROUTE_TABLE_ID = aws_route_table.application.id
      }
    )
  )
}

resource "aws_autoscaling_group" "nat" {
  name                = format(local.resource_name, var.nat_asg_config.name)
  desired_capacity    = var.nat_asg_config.desired_capacity
  max_size            = var.nat_asg_config.max_size
  min_size            = var.nat_asg_config.min_size
  vpc_zone_identifier = [for subnet in aws_subnet.public : subnet.id]
  launch_template {
    id      = aws_launch_template.nat.id
    version = var.nat_asg_config.launch_template_version
  }
  health_check_type         = var.nat_asg_config.health_check_type
  health_check_grace_period = var.nat_asg_config.health_check_grace_period

  dynamic "tag" {
    for_each = local.nat_asg_ec2_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}