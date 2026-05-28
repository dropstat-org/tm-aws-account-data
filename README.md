# tm-aws-account-data

Terraform module that reads shared AWS infrastructure from the current account and exposes it as outputs. Consumers use these outputs to reference the VPC, subnets, and route tables without duplicating data-source lookups across every module.

Works across all Dropstat account types: **workload** (dev/staging/prod), **network**, and **shared-services**.

- [CHANGELOG](CHANGELOG.md)
- [Examples](examples/)

## Usage

Invoke without parameters — the module auto-detects the account from the VPC `Name` tag:

```hcl
module "config" {
  source = "git::https://github.com/dropstat-org/tm-aws-account-data.git?ref=v1.0.0"
}
```

To target a different region, pass a provider alias:

```hcl
module "config" {
  source = "git::https://github.com/dropstat-org/tm-aws-account-data.git?ref=v1.0.0"

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

# Subnets by layer (empty list when a layer has no subnets in the account)
module.config.subnets.publics   # public subnets — NAT GW, ALBs (network account)
module.config.subnets.privates  # workload subnets — ECS tasks, Lambda
module.config.subnets.secures   # TGW attachment ENIs (secu / tgw-attachment)
module.config.subnets.data      # data subnets — Aurora, ElastiCache

# Subnet ID lists (convenience)
[for s in module.config.subnets.privates : s.id]
[for s in module.config.subnets.data     : s.id]

# Route tables by layer
module.config.routes.publics    # map of subnet_id → route_table_id
module.config.routes.privates
module.config.routes.secures

# Account metadata
module.config.account.id
module.config.account.environment  # "dev" | "qa" | "prod" | "network" | "shared-services"
module.config.account.org          # "dropstat"
module.config.account.region       # "us-east-2"
```

### `env_id` — fallback for non-standard VPC names

The module parses `environment` and `org` from the VPC `Name` tag. If the VPC name cannot be parsed, pass it explicitly:

```hcl
module "config" {
  source = "git::https://github.com/dropstat-org/tm-aws-account-data.git?ref=v1.0.0"
  env_id = "dropstat-dev-vpc"
}
```

## Requirements

| Name | Version |
|-----------|---------|
| terraform | >= 1.3  |
| aws       | ~> 5.0  |

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
| `env_id` | Optional. VPC Name tag value (e.g. `dropstat-dev-vpc`). Use when auto-detection fails. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc` | VPC attributes: `id`, `arn`, `cidr_block`, `tags`, `owner_id`, `enable_dns_hostnames`, `enable_dns_support` |
| `subnets` | Subnet lists by layer: `publics`, `privates`, `secures`, `data`. Empty list when a layer has no subnets in the account. |
| `routes` | Route table maps by layer: `publics`, `privates`, `secures`. Each entry is `subnet_id → route_table_id`. |
| `account` | Account metadata: `id`, `name`, `environment`, `org`, `region`. |

## VPC and subnet discovery

The module selects the VPC by matching the `Name` tag against `dropstat-*`.

Subnets are resolved by `subnet-type` tag scoped to the discovered VPC:

| Output layer | `subnet-type` tag | Account | Subnet purpose |
|---|---|---|---|
| `publics` | `public` | network | NAT Gateway, future ALBs |
| `privates` | `workload` | dev / staging / prod / shared-services | ECS tasks, Lambda |
| `secures` | `secu` | dev / staging / prod / shared-services | TGW attachment ENIs |
| `secures` | `tgw-attachment` | network | TGW attachment ENIs in egress VPC |
| `data` | `data` | dev / staging / prod | Aurora, ElastiCache |

Layers with no matching subnets return an empty list — no error.

| Account | VPC name | Populated layers |
|---------|----------|-----------------|
| dev / staging / prod | `dropstat-{env}-vpc` | privates, secures, data |
| network | `dropstat-egress-vpc` | publics, secures |
| shared-services | `dropstat-shared-services-vpc` | privates, secures |

## Contributing

1. Branch off `main` — one branch per feature or fix.
2. Run `terraform fmt` and `terraform validate` before committing.
3. Update [CHANGELOG.md](CHANGELOG.md) following [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.
4. Open a Pull Request against `main` — CI runs `terraform validate` and `checkov` automatically.
