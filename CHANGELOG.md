# Changelog

All notable changes to this module will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.0] - 2026-05-28

### Added

- Initial release adapted for Dropstat multi-account AWS architecture
- VPC discovery scoped to `dropstat-*` naming convention
- Structured `vpc` output (`id`, `arn`, `cidr_block`, `tags`, `owner_id`, `enable_dns_hostnames`, `enable_dns_support`)
- `subnets` output with four layers: `publics`, `privates`, `secures`, `data`
- `secures` layer (network/TGW-attachment subnets) — previously missing despite being documented
- `routes` output with route table maps per layer: `publics`, `privates`, `secures`
- `iam_roles` output with shared roles: `backup_restore`, `ec2_ssm`, `ecs_instance`, `db_monitoring`
- `account` output with metadata derived from VPC name: `id`, `name`, `environment`, `context`, `region`
- `trusted_cidrs` output with list of trusted CIDR blocks
- `env_id` input variable as fallback for non-standard VPC names
- Dev example under `examples/` with real values from the Dropstat dev account (`us-east-2`, `10.1.0.0/18`)
- README in English documenting all inputs, outputs, and usage patterns

[v1.0.0]: https://github.com/dropstat-org/tm-aws-account-data/releases/tag/v1.0.0
