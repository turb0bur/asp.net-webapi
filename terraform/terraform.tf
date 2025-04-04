terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  backend "s3" {
    bucket               = "turb0bur-terraform-state"
    key                  = "aspnet-webapi/terraform.tfstate"
    region               = "eu-central-1"
    workspace_key_prefix = "env"
    dynamodb_table       = "aspnet-webapi-terraform-state-lock"
  }
}
