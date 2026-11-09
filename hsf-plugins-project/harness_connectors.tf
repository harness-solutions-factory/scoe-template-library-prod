resource "harness_platform_connector_docker" "test" {
  identifier  = "dockerhub_hsf_cloud"
  name        = "DockerHub - HSF - Cloud"
  org_id      = module.harness_project.organization_identifier
  project_id  = module.harness_project.project_identifier
  description = "Upstream Connector to push images into the official HSF Docker Hub Repository"
  tags        = local.common_tags_tuple
  type        = "DockerHub"
  url         = "https://index.docker.io/v2/"
  credentials {
    username     = "harnesssolutionfactory"
    password_ref = harness_platform_secret_text.dockerhub_harnesssolutionfactory.id
  }
}
