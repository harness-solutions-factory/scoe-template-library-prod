module "harness_project" {
  source = "../harness-project"

  harness_platform_url     = var.harness_platform_url
  harness_platform_account = var.harness_platform_account

  organization_id = var.organization_id

  project_id          = local.fmt_identifier
  project_name        = var.project_name
  project_description = var.project_description

  tags = var.tags

}

data "harness_platform_permissions" "current" {}
