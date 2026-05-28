data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "selected_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dropstat-*"]
  }
}

# ── Subnet ID lists per layer ─────────────────────────────────────────────────
# All filters scope to the discovered VPC to avoid cross-VPC matches.
# subnet-type tags are set by _modules/workload-vpc and _modules/network-hub.

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected_vpc.id]
  }
  filter {
    name   = "tag:subnet-type"
    values = ["public"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected_vpc.id]
  }
  filter {
    name   = "tag:subnet-type"
    values = ["workload"]
  }
}

data "aws_subnets" "network_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected_vpc.id]
  }
  # "secu"           → workload accounts (TGW attachment ENIs)
  # "tgw-attachment" → network account  (TGW attachment ENIs in egress VPC)
  filter {
    name   = "tag:subnet-type"
    values = ["secu", "tgw-attachment"]
  }
}

data "aws_subnets" "data_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected_vpc.id]
  }
  filter {
    name   = "tag:subnet-type"
    values = ["data"]
  }
}

# ── Individual subnet objects (for attribute access) ──────────────────────────

data "aws_subnet" "publics" {
  for_each = toset(data.aws_subnets.public_subnets.ids)
  id       = each.value
}

data "aws_subnet" "privates" {
  for_each = toset(data.aws_subnets.private_subnets.ids)
  id       = each.value
}

data "aws_subnet" "networks" {
  for_each = toset(data.aws_subnets.network_subnets.ids)
  id       = each.value
}

data "aws_subnet" "data" {
  for_each = toset(data.aws_subnets.data_subnets.ids)
  id       = each.value
}

# ── Route tables ──────────────────────────────────────────────────────────────

data "aws_route_tables" "all_route_tables" {
  vpc_id = data.aws_vpc.selected_vpc.id
}

data "aws_route_table" "specific_route_table" {
  for_each = toset(data.aws_route_tables.all_route_tables.ids)

  route_table_id = each.value
  depends_on     = [data.aws_route_tables.all_route_tables]
}

locals {
  subnet_public_route_table_map = {
    for subnet in data.aws_subnets.public_subnets.ids : subnet => try(
      [for rt in data.aws_route_table.specific_route_table : rt.id if contains(rt.associations[*].subnet_id, subnet)][0],
      {}
    )
  }

  subnet_private_route_table_map = {
    for subnet in data.aws_subnets.private_subnets.ids : subnet => try(
      [for rt in data.aws_route_table.specific_route_table : rt.id if contains(rt.associations[*].subnet_id, subnet)][0],
      {}
    )
  }

  subnet_network_route_table_map = {
    for subnet in data.aws_subnets.network_subnets.ids : subnet => try(
      [for rt in data.aws_route_table.specific_route_table : rt.id if contains(rt.associations[*].subnet_id, subnet)][0],
      {}
    )
  }
}
