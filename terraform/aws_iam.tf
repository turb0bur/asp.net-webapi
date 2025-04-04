##########################################################################################
# IAM instance role for WebAPI application EC2 instances
##########################################################################################
resource "aws_iam_role" "application_ec2" {
  name = format(local.resource_name, "application-ec2-role")
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "application_ssm_role_policy" {
  role       = aws_iam_role.application_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.application_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "application_profile" {
  name = format(local.resource_name, "application-profile")
  role = aws_iam_role.application_ec2.name
}

##########################################################################################
# IAM role for NAT EC2 instance
##########################################################################################
resource "aws_iam_role" "nat_ec2" {
  name = format(local.resource_name, "nat-ec2-role")
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "nat_profile" {
  name = format(local.resource_name, "nat-profile")
  role = aws_iam_role.nat_ec2.name
}

resource "aws_iam_role_policy_attachment" "nat_ssm_role_policy" {
  role       = aws_iam_role.nat_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ec2_create_route" {
  name = format(local.resource_name, "ec2-create-route-policy")
  role = aws_iam_role.nat_ec2.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ec2:CreateRoute",
        Resource = format("arn:aws:ec2:%s:%s:route-table/*", var.region, data.aws_caller_identity.current.account_id)
      }
    ]
  })
}

resource "aws_iam_role_policy" "modify_instance_attribute" {
  name = format(local.resource_name, "modify-instance-attribute-policy")
  role = aws_iam_role.nat_ec2.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ec2:ModifyInstanceAttribute",
        Resource = format("arn:aws:ec2:%s:%s:instance/*", var.region, data.aws_caller_identity.current.account_id)
      }
    ]
  })
}

##########################################################################################
# IAM role grants ECS tasks permission to pull images from ECR and send logs to CloudWatch
##########################################################################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = format(local.resource_name, "ecs-task-execution-role")
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = format(local.resource_name, "ecs-task-execution-role")
  }
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_execution_role_read_ssm_policy" {
  name = format(local.resource_name, "ecs-task-execution-role-read-ssm-policy")
  role = aws_iam_role.ecs_task_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParameterHistory"
        ],
        Resource = [
          format(
            "arn:aws:ssm:%s:%s:parameter/%s/db/*",
            var.region,
            data.aws_caller_identity.current.account_id,
            local.param_store_prefix
          ),
        ]
      }
    ]
  })
}
