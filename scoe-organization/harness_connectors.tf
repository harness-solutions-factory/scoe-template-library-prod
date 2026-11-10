resource "harness_platform_connector_aws" "oidc" {
  identifier  = "OIDC"
  name        = "OIDC"
  description = "Standard AWS Access via OIDC"
  org_id      = module.harness_organization.organization_identifier
  tags        = local.common_tags_tuple

  oidc_authentication {
    iam_role_arn = var.aws_oidc_iam_role_arn
    region       = var.aws_oidc_iam_role_region
  }
}
