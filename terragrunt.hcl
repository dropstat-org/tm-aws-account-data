locals {
  pipe         = yamldecode(file("./pipeline.yml"))
  product_id   = lower(local.pipe.metadata.productId)
  component_id = lower(local.pipe.metadata.componentId)
}

terraform {
  // El timeout de este lock debe ser adecuado para esperar al componente mas lento (Pj. BBDD)
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=40m"]
  }

  extra_arguments "product_vars" {
    commands  = get_terraform_commands_that_need_vars()
    arguments = []
  }
}

remote_state {
  backend = "s3"

  config = {
    bucket     = "250441039407-iac7r4n5b4nk-pci-us-east-1"
    key        = "${local.product_id}/${local.component_id}/${path_relative_to_include()}/terraform.tfstate"
    region     = "us-east-1"
    access_key = get_env("AWS_PCIC2_P_SDLC_ACCESS_KEY", "")
    secret_key = get_env("AWS_PCIC2_P_SDLC_SECRET_KEY", "")
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {}
  required_version = ">= 1.3"

  required_providers {
    aws    = ">= 5.0"
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "${get_env("AWS_PCINO_D_SECU_ACCESS_KEY", "")}"
  secret_key = "${get_env("AWS_PCINO_D_SECU_SECRET_KEY", "")}"
}
EOF
}
