module "harness_organization" {
  source = "../harness-organization"

  harness_platform_url     = var.harness_platform_url
  harness_platform_account = var.harness_platform_account

  organization_id          = local.fmt_identifier
  organization_name        = var.organization_name
  organization_description = var.organization_description

  tags = var.tags

}
