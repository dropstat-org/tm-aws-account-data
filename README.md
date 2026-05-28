# tm_config

Terraform module that reads shared AWS infrastructure from the current account and exposes it as outputs. Consumers use these outputs to reference the VPC, subnets, route tables, and IAM roles without duplicating data-source lookups across every module.

- [CHANGELOG](CHANGELOG.md)
- [Examples](examples/)

## Usage

Invoke without parameters — the module auto-detects the account from the VPC name tag:

```hcl
module "config" {
  source = "git::https://github.com/dropstat-org/tm_config.git?ref=v1.0.0"
}
```

To target a different region, pass a provider alias:

```hcl
module "config" {
  source = "git::https://github.com/dropstat-org/tm_config.git?ref=v1.0.0"

  providers = {
    aws = aws.us-east-2
  }
}
```

### Referencing outputs

```hcl
# VPC
module.config.vpc.id
module.config.vpc.cidr_block
module.config.vpc.tags

# Subnets by layer
module.config.subnets.publics   # list of aws_subnet objects
module.config.subnets.privates
module.config.subnets.secures   # network / TGW-attachment subnets
module.config.subnets.data

# Route tables by layer
module.config.routes.publics    # map of subnet_id → route_table_id
module.config.routes.privates
module.config.routes.secures

# IAM roles
module.config.iam_roles.ec2_ssm.role_arn
module.config.iam_roles.ecs_instance.role_arn
module.config.iam_roles.db_monitoring.role_arn
module.config.iam_roles.backup_restore.role_arn

# Account metadata
module.config.account.id
module.config.account.environment  # "dev" | "qa" | "prod"
module.config.account.context      # "npci" | "c2" | "cde"
module.config.account.region
```

### `env_id` — fallback for non-standard VPC names

The module parses `account`, `environment`, and `context` from the VPC `Name` tag. If your VPC name does not follow the standard pattern (`pci-<context>-<env>-<name>` or `<context>-<env>-<name>`), pass the account ID manually:

```hcl
module "config" {
  source = "git::https://github.com/dropstat-org/tm_config.git?ref=v1.0.0"
  env_id = "pcino-d-secu"
}
```

## Requirements

| Name | Version |
|-----------|---------|
| terraform | >= 1.3  |
| aws       | ~> 5.0  |
| random    | ~> 3.1  |

## Providers

| Name | Version |
|-----|---------|
| aws | ~> 5.0  |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.selected_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_subnets.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.network_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.data_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnet.publics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.privates](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.networks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_route_tables.all_route_tables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_route_table.specific_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `env_id` | Optional. Account ID (e.g. `pcino-d-proc`). Required when the VPC name does not match the standard naming pattern. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc` | VPC data: `id`, `arn`, `cidr_block`, `tags`, `owner_id`, `enable_dns_hostnames`, `enable_dns_support` |
| `subnets` | Subnet lists grouped by layer: `publics`, `privates`, `secures`, `data`. Each entry is an [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) object. |
| `routes` | Route table maps grouped by layer: `publics`, `privates`, `secures`. Each entry is a `subnet_id → route_table_id` map. |
| `iam_roles` | Map of common IAM roles and instance profiles: `backup_restore`, `ec2_ssm`, `ecs_instance`, `db_monitoring`. |
| `account` | Account metadata derived from the VPC name: `id`, `name`, `environment`, `context`, `region`. |
| `trusted_cidrs` | List of trusted CIDR blocks with description and ownership flag. |

## VPC discovery

The module selects the VPC by matching the `Name` tag against `dropstat-*` (e.g. `dropstat-dev-vpc`, `dropstat-prod-vpc`).

Subnets are resolved by `Name` tag:

| Layer | Tag values |
|-------|-----------|
| public | `A1_Public_Subnet`, `A2_Public_Subnet`, `A3_Public_Subnet` |
| private | `D1_Private_Subnet`, `D2_Private_Subnet`, `D3_Private_Subnet` |
| secures (network) | `B1_Private_Network_Subnet`, `B2_Private_Network_Subnet`, `B3_Private_Network_Subnet` |
| data | `C1_Private_Data_Subnet`, `C2_Private_Data_Subnet`, `C3_Private_Data_Subnet` |

## Contributing

1. Branch off `main` — one branch per feature or fix.
2. Run `terraform fmt` and `terraform validate` before committing.
3. Update [CHANGELOG.md](CHANGELOG.md) following [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.
4. Open a Pull Request against `main` — CI runs `terraform validate` and `checkov` automatically.
