locals {
  rgx             = "pci-(?P<context>\\w+)-(?P<env_short>\\w+)-(?P<name>[\\w-]+)"
  rgx_aux         = "(?P<context>\\w+)-(?P<env_short>\\w+)-(?P<name>[\\w-]+)"
  current_account = lookup(data.aws_vpc.selected_vpc.tags, "Name", null)

  account_parsed = local.current_account != null ? try(regex(local.rgx_aux, var.env_id), try(regex(local.rgx, local.current_account), regex(local.rgx_aux, local.current_account))) : {}

  account = local.current_account != null ? {
    name        = local.account_parsed.name
    environment = { d = "dev", p = "prod", q = "qa", dev = "dev", qa = "qa", prod = "prod", prd = "prod" }[local.account_parsed.env_short]
    context     = { non = "npci", c2 = "c2", cde = "cde", pcino = "npci", pcic2 = "c2", pcicde = "cde" }[local.account_parsed.context]
    region      = data.aws_region.current.name
    id          = data.aws_caller_identity.current.account_id
    } : {
    name        = null
    environment = null
    context     = null
    region      = null
    id          = null
  }
}
