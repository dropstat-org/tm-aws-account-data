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
  description = "Datos de la VPC obtenidos a partir de un recurso [aws_vpc](https://www.terraform.io/docs/providers/aws/d/vpc.html)"
}

output "subnets" {
  value = {
    publics  = values(data.aws_subnet.publics)
    privates = values(data.aws_subnet.privates)
    secures  = values(data.aws_subnet.networks)
    data     = values(data.aws_subnet.data)
  }
  description = "Listas de subnets agrupadas por capa `publics`, `privates`, `secures` y `data`. Cada una de las subnets es un recurso [aws_subnet](https://www.terraform.io/docs/providers/aws/d/subnet.html)"
}

output "routes" {
  value = {
    publics  = local.subnet_public_route_table_map
    privates = local.subnet_private_route_table_map
    secures  = local.subnet_network_route_table_map
  }
  description = "Listas de tablas de ruta agrupadas por capa `publics`, `privates` y `secures`. Cada una de las tablas de ruta es un recurso [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table)"
}


output "iam_roles" {
  value = {
    backup_restore = {
      role_arn    = format("arn:aws:iam::%v:role/bs/bs-backup-restore", data.aws_caller_identity.current.account_id)
      profile_arn = format("arn:aws:iam::%v:instance-profile/bs/bs-backup-restore", data.aws_caller_identity.current.account_id)
      name        = "bs-backup-restore"
    }
    ec2_ssm = {
      role_arn    = format("arn:aws:iam::%v:role/bs/bs-ec2-ssm", data.aws_caller_identity.current.account_id)
      profile_arn = format("arn:aws:iam::%v:instance-profile/bs/bs-ec2-ssm", data.aws_caller_identity.current.account_id)
      name        = "bs-ec2-ssm"
    }
    ecs_instance = {
      role_arn    = format("arn:aws:iam::%v:role/bs/bs-ecs-instance", data.aws_caller_identity.current.account_id)
      profile_arn = format("arn:aws:iam::%v:instance-profile/bs-ecs-instance", data.aws_caller_identity.current.account_id)
      name        = "bs-ecs-instance"
    }
    db_monitoring = {
      role_arn    = format("arn:aws:iam::%v:role/bs/bs-rds-monitoring", data.aws_caller_identity.current.account_id)
      profile_arn = format("arn:aws:iam::%v:instance-profile/bs/bs-rds-monitoring", data.aws_caller_identity.current.account_id)
      name        = "bs-rds-monitoring"
    }
  }
  description = "Mapa con los nombres, y ARNs de roles y perfiles de uso comun."
}

output "account" {
  description = "Account metadata derived from the VPC name: id, name, environment, org, region."
  value       = local.account
}

output "trusted_cidrs" {
  value = [
    { cidr = "10.212.0.0/16", description = "bloque aws us-east-1", own = true },
    { cidr = "18.211.208.47/32", description = "acc arq3x3 nat 1", own = true },
    { cidr = "3.210.74.10/32", description = "acc arq3x3 nat 2", own = true },
    { cidr = "3.216.226.47/32", description = "acc arq3x3 nat 3", own = true },
    { cidr = "3.217.121.232/32", description = "acc sdlc nat 1", own = true },
    { cidr = "3.217.212.219/32", description = "acc sdlc nat 2", own = true },
    { cidr = "34.198.156.77/32", description = "acc sdlc nat 3", own = true },
    { cidr = "190.196.61.28/32", description = "wifi calipso 1", own = true },
    { cidr = "190.54.13.65/32", description = "wifi calipso 2", own = true },
    { cidr = "200.10.13.150/32", description = "wifi celular - Maxwell", own = true },
    { cidr = "200.10.13.151/32", description = "wifi planck 1", own = true }
  ]
  description = "Listado de CIDR's considerados de confianza."
}


#EKS
output "eks_workers_non_routable_subnets" {
  value       = local.eks_workers_non_routable_subnets
  description = "Mapa con los segmentos no-routables para asignar a los workloads de clusters EKS"
}

output "eks_secondary_cidrs" {
  value       = local.eks_secondary_cidrs
  description = "Bloque de direcciones para workloads de clusters EKS"
}
