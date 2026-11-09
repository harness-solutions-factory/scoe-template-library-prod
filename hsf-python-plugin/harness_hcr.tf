resource "harness_platform_repo" "hcr" {
  identifier     = var.repository_name
  org_id         = data.harness_platform_organization.selected.id
  project_id     = data.harness_platform_project.selected.id
  default_branch = "main"
  description    = var.repository_description
}
