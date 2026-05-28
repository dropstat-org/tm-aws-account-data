# Dev account example — dropstat-dev-vpc (10.1.0.0/18, us-east-2)
#
# This module call runs inside the dev account. The provider assumes
# TerraformCI in that account (see examples/provider.tf).
#
# The module finds the VPC by matching the Name tag ("dropstat-dev-vpc")
# and resolves all subnets, route tables, and shared IAM roles from it.

module "config" {
  source = "git::https://github.com/dropstat-org/tm-aws-account-data.git?ref=v1.0.0"
  env_id = "dropstat-dev-vpc"
}

# ── VPC ───────────────────────────────────────────────────────────────────────

locals {
  vpc_id   = module.config.vpc.id        # attach security groups, VPC endpoints
  vpc_cidr = module.config.vpc.cidr_block  # 10.1.0.0/18

  # ── Subnets ─────────────────────────────────────────────────────────────────

  # private — 10.1.0.0/21 × 3 AZs (2 043 usable IPs each)
  # ECS Fargate tasks, Lambda functions
  private_subnet_ids = [for s in module.config.subnets.privates : s.id]

  # data — 10.1.24.0/26 × 3 AZs (59 usable IPs each)
  # Aurora Serverless v2, ElastiCache Redis — no route to internet
  data_subnet_ids = [for s in module.config.subnets.data : s.id]

  # secures — 10.1.25.0/27 × 3 AZs (27 usable IPs each)
  # TGW attachment ENIs only — no route to NAT Gateway
  secu_subnet_ids = [for s in module.config.subnets.secures : s.id]

  # ── Route tables ─────────────────────────────────────────────────────────────

  # private route tables already carry 0.0.0.0/0 → TGW → Network account NAT
  private_route_table_ids = values(module.config.routes.privates)

  # ── IAM ──────────────────────────────────────────────────────────────────────

  ecs_instance_role_arn  = module.config.iam_roles.ecs_instance.role_arn
  db_monitoring_role_arn = module.config.iam_roles.db_monitoring.role_arn
  ec2_ssm_role_arn       = module.config.iam_roles.ec2_ssm.role_arn

  # ── Account metadata ─────────────────────────────────────────────────────────

  account_id  = module.config.account.id
  environment = module.config.account.environment  # "dev"
  org         = module.config.account.org          # "dropstat"
  region      = module.config.account.region       # "us-east-2"
}
