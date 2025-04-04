region      = "eu-central-1"
environment = "dev"

vpc_settings = {
  name                 = "main-vpc"
  cidr                 = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

subnet_settings = {
  public = {
    subnet1 = {
      map_public_ip_on_launch = true
      name                    = "public-subnet-1"
      cidr                    = "10.10.1.0/24"
    }
    subnet2 = {
      map_public_ip_on_launch = true
      name                    = "public-subnet-2"
      cidr                    = "10.10.2.0/24"
    }
  }

  app = {
    subnet1 = {
      name = "app-subnet-1"
      cidr = "10.10.10.0/24"
    }
    subnet2 = {
      name = "app-subnet-2"
      cidr = "10.10.20.0/24"
    }
  }
}

webapi_instances_config = {
  instance_type        = "t3.medium"
  template_prefix_name = "private-instance-"
  root_volume_name     = "/dev/xvda"
  ebs_volume = {
    size                  = 30
    type                  = "gp3"
    delete_on_termination = true
  }
}

webapi_asg_config = {
  name                      = "webapi-asg"
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 1
  launch_template_version   = "$Latest"
  health_check_type         = "EC2"
  health_check_grace_period = 300
  tags = {
    Name = "private-asg-instance"
  }
}

nat_instances_config = {
  instance_type        = "t2.micro"
  template_prefix_name = "nat-instance-"
  root_volume_name     = "/dev/xvda"
  ebs_volume = {
    size                  = 8
    type                  = "gp3"
    delete_on_termination = true
  }
}

nat_asg_config = {
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

ecs_cluster_config = {
  name = "cluster"
  task_definitions = {
    webapi = {
      family                   = "task"
      network_mode             = "bridge"
      requires_compatibilities = ["EC2"]
      container = {
        name   = "webapi"
        port   = 80
        cpu    = 1000
        memory = 1024
      }
      aspnetcore_env = {
        ASPNETCORE_ENVIRONMENT = "Development",
        ASPNETCORE_URLS        = "http://+:80"
      }
    }
  }
  services = {
    webapi = {
      name          = "service"
      desired_count = 4
      deployment = {
        min_percent = 50
        max_percent = 200
      }
    }
  }
}
