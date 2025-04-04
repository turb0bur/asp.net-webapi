locals {
  resource_name = join("-", [var.region, var.environment, var.application_name, "%s"])

  public_subnet_names = { for k, v in var.subnet_settings.public : k => format(local.resource_name, v.name) }
  public_subnet_cidrs = { for k, v in var.subnet_settings.public : k => v.cidr }

  app_subnet_names = { for k, v in var.subnet_settings.app : k => format(local.resource_name, v.name) }
  app_subnet_cidrs = { for k, v in var.subnet_settings.app : k => v.cidr }

  webapi_asg_ec2_tags = merge({ Environment = var.environment }, var.webapi_asg_config.tags)
  nat_asg_ec2_tags    = merge({ Environment = var.environment }, var.nat_asg_config.tags)

  param_store_prefix = format("%s/webapi", var.environment)
}