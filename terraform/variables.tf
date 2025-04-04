variable "region" {
  description = "The AWS region"
  type        = string
}

variable "environment" {
  description = "The environment"
  type        = string
}

variable "application_name" {
  description = "The name of the application"
  type        = string
  default     = "webapi"
}

variable "ecr_repository_uri" {
  description = "The ECR repository URI for the ASP.NET WebAPI application"
  type        = string
  default     = "278336501300.dkr.ecr.eu-central-1.amazonaws.com/turb0bur/aspnet-webapi"
}

variable "api_image_tag" {
  description = "Tag of the Docker image for the ASP.NET WebAPI application"
  type        = string
  default     = "latest"
}

variable "vpc_settings" {
  description = "The common settings for the VPC"
  type = object({
    name                 = string
    cidr                 = string
    enable_dns_support   = bool
    enable_dns_hostnames = bool
  })
}

variable "subnet_settings" {
  description = "The settings for the subnets"
  type = object({
    public = map(object({
      map_public_ip_on_launch = bool
      name                    = string
      cidr                    = string
    }))
    app = map(object({
      name = string
      cidr = string
    }))
  })
}

variable "igw_settings" {
  description = "The settings for the internet gateway"
  type = object({
    name = string
  })
  default = {
    name = "main-igw"
  }
}

variable "public_route_table_settings" {
  description = "The settings for the public subnet route table"
  type = object({
    routes = map(object({
      cidr_block = string
    }))
    name = string
  })
  default = {
    routes = {
      internet = {
        cidr_block = "0.0.0.0/0"
      }
    }
    name = "public-route-table"
  }
}

variable "app_route_table_settings" {
  description = "The settings for the application subnet route table"
  type = object({
    routes = map(object({
      cidr_block = string
    }))
    name = string
  })
  default = {
    routes = {
      internet = {
        cidr_block = "0.0.0.0/0"
      }
    }
    name = "app-route-table"
  }
}

variable "webapi_instances_config" {
  description = "The configuration for the application instances for ECS pool"
  type = object({
    instance_type        = string
    template_prefix_name = string
    root_volume_name     = string
    ebs_volume = object({
      size                  = number
      type                  = string
      delete_on_termination = bool
    })
  })
}

variable "webapi_asg_config" {
  description = "The configuration for auto scaling group for API application"
  type = object({
    name                      = string
    desired_capacity          = number
    max_size                  = number
    min_size                  = number
    launch_template_version   = string
    health_check_type         = string
    health_check_grace_period = number
    tags                      = map(string)
  })
}

variable "public_alb_sg_settings" {
  description = "The settings for the Internet-faced Application Load Balancer security group"
  type = object({
    name = string
  })
  default = {
    name = "public-alb-sg"
  }
}

variable "private_instances_sg_settings" {
  description = "The settings for the security group for the private instances"
  type = object({
    name = string
  })
  default = {
    name = "private-app-sg"
  }
}

variable "public_alb_config" {
  description = "The configuration for the Internet-faced Application Load Balancer"
  type = object({
    name    = string
    tg_name = string
  })
  default = {
    name    = "alb"
    tg_name = "tg"
  }
}

variable "ecs_cluster_config" {
  description = "The name of the ECS cluster"
  type = object({
    name = string
    task_definitions = map(object({
      family                   = string
      network_mode             = string
      requires_compatibilities = list(string)
      container = object({
        name   = string
        port  = string
        cpu    = number
        memory = number
      })
      aspnetcore_env = map(string)
    }))
    services = map(object({
      name          = string
      desired_count = number
      deployment = object({
        min_percent = number
        max_percent = number
      })
    }))
  })
}

variable "nat_instances_config" {
  description = "The configuration for the NAT instances"
  type = object({
    instance_type        = string
    template_prefix_name = string
    root_volume_name     = string
    ebs_volume = object({
      size                  = number
      type                  = string
      delete_on_termination = bool
    })
  })
}

variable "nat_asg_config" {
  type = object({
    name                      = string
    desired_capacity          = number
    max_size                  = number
    min_size                  = number
    launch_template_version   = string
    health_check_type         = string
    health_check_grace_period = number
    tags                      = map(string)
  })
  description = "The configuration for the NAT auto scaling group"
  default = {
    name                      = "nat-asg"
    desired_capacity          = 1
    max_size                  = 1
    min_size                  = 1
    launch_template_version   = "$Latest"
    health_check_type         = "EC2"
    health_check_grace_period = 300
    tags = {
      Name = "nat-asg-instance"
    }
  }
}

variable "nat_sg_settings" {
  description = "The settings for the NAT security group"
  type = object({
    name = string
  })
  default = {
    name = "nat-sg"
  }
}
