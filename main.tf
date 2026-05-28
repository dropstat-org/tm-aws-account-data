data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "selected_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dropstat-*"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["A1_Public_Subnet", "A2_Public_Subnet", "A3_Public_Subnet"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Name"
    values = ["D1_Private_Subnet", "D2_Private_Subnet", "D3_Private_Subnet"]
  }
}

data "aws_subnets" "network_subnets" {
  filter {
    name   = "tag:Name"
    values = ["B1_Private_Network_Subnet", "B2_Private_Network_Subnet", "B3_Private_Network_Subnet"]
  }
}

data "aws_subnets" "data_subnets" {
  filter {
    name   = "tag:Name"
    values = ["C1_Private_Data_Subnet", "C2_Private_Data_Subnet", "C3_Private_Data_Subnet"]
  }
}


data "aws_subnet" "publics" {
  for_each = toset(data.aws_subnets.public_subnets.ids)

  id = each.value
}

data "aws_subnet" "privates" {
  for_each = toset(data.aws_subnets.private_subnets.ids)

  id = each.value
}

data "aws_subnet" "data" {
  for_each = toset(data.aws_subnets.data_subnets.ids)

  id = each.value
}

data "aws_subnet" "networks" {
  for_each = toset(data.aws_subnets.network_subnets.ids)

  id = each.value
}


data "aws_route_tables" "all_route_tables" {
  vpc_id = data.aws_vpc.selected_vpc.id
}

data "aws_route_table" "specific_route_table" {
  for_each = toset(data.aws_route_tables.all_route_tables.ids)

  route_table_id = each.value
  depends_on     = [data.aws_route_tables.all_route_tables]
}

locals {
  subnet_network_route_table_map = {
    for subnet in data.aws_subnets.network_subnets.ids : subnet => try(
      (
        [for rt in data.aws_route_table.specific_route_table : rt.id if contains(rt.associations[*].subnet_id, subnet)][0]
      ),
      {}
    )
  }

  subnet_public_route_table_map = {
    for subnet in data.aws_subnets.public_subnets.ids : subnet => try(
      (
        [for rt in data.aws_route_table.specific_route_table : rt.id if contains(rt.associations[*].subnet_id, subnet)][0]
      ),
      {}
    )
  }

  subnet_private_route_table_map = {
    for subnet in data.aws_subnets.private_subnets.ids : subnet => try(
      (
        [for rt in data.aws_route_table.specific_route_table : rt.id if contains(rt.associations[*].subnet_id, subnet)][0]
      ),
      {}
    )
  }
}
