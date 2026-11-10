resource "harness_platform_secret_text" "hsf_github" {
  identifier  = "hsf_github"
  name        = "HSF GitHub Credentials"
  org_id      = module.harness_organization.organization_identifier
  description = "See Jeremy before changing or updating"
  tags        = local.common_tags_tuple

  secret_manager_identifier = "org.harnessSecretManager"
  value_type                = "Inline"
  value                     = "changeme"
}
