resource "harness_platform_pipeline" "pipeline" {
  identifier  = local.fmt_identifier
  name        = var.pipeline_name
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "Scan, Build and Publish for ${var.pipeline_name}"
  yaml = templatefile(
    "${path.module}/templates/pipelines/pipe_Python_Application.yaml",
    {
      # Pipeline Setup Details
      PIPELINE_IDENTIFIER : local.fmt_identifier
      PIPELINE_NAME : var.pipeline_name
      PIPELINE_DESCRIPTION : "Scan, Build and Publish for ${var.pipeline_name}"
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id

      REGISTRY_NAME : "harnesssolutionfactory"
      REPOSITORY_NAME : var.repository_name

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}
