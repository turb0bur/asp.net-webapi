data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_nat" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*-x86_64-ebs"]
  }
}

data "aws_ami" "amazon_linux_ecs" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}
