locals {
  rgx             = "(?P<org>\\w+)-(?P<env_short>\\w+)-(?P<name>[\\w-]+)"
  current_account = lookup(data.aws_vpc.selected_vpc.tags, "Name", null)

  account_parsed = local.current_account != null ? try(
    regex(local.rgx, var.env_id),
    regex(local.rgx, local.current_account)
  ) : {}

  account = local.current_account != null ? {
    name        = local.account_parsed.name
    environment = { dev = "dev", d = "dev", qa = "qa", q = "qa", prod = "prod", p = "prod", prd = "prod" }[local.account_parsed.env_short]
    org         = local.account_parsed.org
    region      = data.aws_region.current.name
    id          = data.aws_caller_identity.current.account_id
    } : {
    name        = null
    environment = null
    org         = null
    region      = null
    id          = null
  }
}
