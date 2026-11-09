resource "harness_platform_secret_text" "dockerhub_harnesssolutionfactory" {
  identifier  = "dockerhub_harnesssolutionfactory"
  name        = "DockerHub - harnesssolutionfactory"
  org_id      = module.harness_project.organization_identifier
  project_id  = module.harness_project.project_identifier
  description = "Upstream Connector Credentials for DockerHub Username - harnesssolutionfactory"
  tags        = local.common_tags_tuple

  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = "changeme"
}

