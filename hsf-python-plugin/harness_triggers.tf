
resource "harness_platform_triggers" "branch_creation" {
  identifier  = "Branch_Creation"
  name        = "Branch Creation"
  target_id   = harness_platform_pipeline.pipeline.id
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "This trigger will fire when a new branch is created."
  yaml = templatefile(
    "${path.module}/templates/pipelines/triggers/branch_creation.yaml",
    {
      # Trigger Setup Details
      TRIGGER_IDENTIFIER : "Branch_Creation"
      TRIGGER_NAME : "Branch Creation"
      PIPELINE_IDENTIFIER : harness_platform_pipeline.pipeline.id
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      DESCRIPTION : "This trigger will fire when a new branch is created."
      REPOSITORY_NAME : var.repository_name

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}

resource "harness_platform_triggers" "push_trigger" {
  identifier  = "Branch_Push"
  name        = "Branch Push"
  target_id   = harness_platform_pipeline.pipeline.id
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "This trigger will fire when a branch is pushed."
  yaml = templatefile(
    "${path.module}/templates/pipelines/triggers/push_trigger.yaml",
    {
      # Trigger Setup Details
      TRIGGER_IDENTIFIER : "Branch_Push"
      TRIGGER_NAME : "Branch Push"
      PIPELINE_IDENTIFIER : harness_platform_pipeline.pipeline.id
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      DESCRIPTION : "This trigger will fire when a branch is pushed."
      REPOSITORY_NAME : var.repository_name

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}

resource "harness_platform_triggers" "pull_request_trigger" {
  identifier  = "Pull_Request"
  name        = "Pull Request"
  target_id   = harness_platform_pipeline.pipeline.id
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "This trigger will fire when a PullRequest is opened."
  yaml = templatefile(
    "${path.module}/templates/pipelines/triggers/pr_trigger.yaml",
    {
      # Trigger Setup Details
      TRIGGER_IDENTIFIER : "Pull_Request"
      TRIGGER_NAME : "Pull Request"
      PIPELINE_IDENTIFIER : harness_platform_pipeline.pipeline.id
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      DESCRIPTION : "This trigger will fire when a PullRequest is opened."
      REPOSITORY_NAME : var.repository_name

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}

resource "harness_platform_triggers" "release_trigger" {
  identifier  = "Release_Trigger"
  name        = "Release Trigger"
  target_id   = harness_platform_pipeline.pipeline.id
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "This trigger will fire upon merge into Main"
  yaml = templatefile(
    "${path.module}/templates/pipelines/triggers/release_trigger.yaml",
    {
      # Trigger Setup Details
      TRIGGER_IDENTIFIER : "Release_Trigger"
      TRIGGER_NAME : "Release Trigger"
      PIPELINE_IDENTIFIER : harness_platform_pipeline.pipeline.id
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      DESCRIPTION : "This trigger will fire upon merge into Main"
      REPOSITORY_NAME : var.repository_name

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}
