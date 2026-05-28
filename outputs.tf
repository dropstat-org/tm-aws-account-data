output "vpc" {
  value = {
    id                   = data.aws_vpc.selected_vpc.id
    arn                  = data.aws_vpc.selected_vpc.arn
    cidr_block           = data.aws_vpc.selected_vpc.cidr_block
    tags                 = data.aws_vpc.selected_vpc.tags
    owner_id             = data.aws_vpc.selected_vpc.owner_id
    enable_dns_hostnames = data.aws_vpc.selected_vpc.enable_dns_hostnames
    enable_dns_support   = data.aws_vpc.selected_vpc.enable_dns_support
  }
  description = "VPC attributes for the current account."
}

output "subnets" {
  value = {
    publics  = values(data.aws_subnet.publics)
    privates = values(data.aws_subnet.privates)
    secures  = values(data.aws_subnet.networks)
    data     = values(data.aws_subnet.data)
  }
  description = "Subnet lists grouped by layer. Empty list when a layer has no subnets in the account (e.g. data in network account)."
}

output "routes" {
  value = {
    publics  = local.subnet_public_route_table_map
    privates = local.subnet_private_route_table_map
    secures  = local.subnet_network_route_table_map
  }
  description = "Route table maps grouped by layer. Each entry is subnet_id -> route_table_id."
}

output "account" {
  value       = local.account
  description = "Account metadata derived from the VPC name: id, name, environment, org, region."
}
