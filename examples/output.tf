output "vpc" {
  value       = module.config.vpc
  description = "VPC data for the dev account"
}

output "subnets" {
  value       = module.config.subnets
  description = "Subnet lists grouped by layer: privates, data, secures"
}

output "routes" {
  value       = module.config.routes
  description = "Route table maps grouped by layer: privates, secures"
}

output "iam_roles" {
  value       = module.config.iam_roles
  description = "Shared IAM roles: ecs_instance, db_monitoring, ec2_ssm, backup_restore"
}

output "account" {
  value       = module.config.account
  description = "Account metadata: id, environment, context, region"
}

output "trusted_cidrs" {
  value       = module.config.trusted_cidrs
  description = "Trusted CIDR blocks for security group ingress rules"
}
