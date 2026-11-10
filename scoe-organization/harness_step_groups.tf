resource "harness_platform_template" "CI_Automated_ChangeLog_and_Tag_Management" {
  depends_on   = [harness_time_sleep.org_setup]
  identifier   = "CI_Automated_ChangeLog_and_Tag_Management"
  name         = "CI Automated ChangeLog and Tag Management"
  org_id       = module.harness_organization.organization_identifier
  version      = "v1"
  is_stable    = true
  force_delete = true
  template_yaml = templatefile(
    "${path.module}/templates/step_groups/stg_CI_Automated_ChangeLog_and_Tag_Management.yaml",
    {
      TEMPLATE_IDENTIFIER : "CI_Automated_ChangeLog_and_Tag_Management"
      TEMPLATE_NAME : "CI Automated ChangeLog and Tag Management"
      TEMPLATE_VERSION : "v1"
      ORGANIZATION_ID : module.harness_organization.organization_identifier
      TEMPLATE_DESC : <<EOF
        Requires CI-module and that the repository contains the `.ai/repository_tasks` configuration files.
        Will use the AI worker Agent `org.ca_scoe_repository_readiness_evaluation` to perform an automated audit of the changes in the current codebase to then update the CHANGELOG and README files , along with creating a new TAG based on repository rules.

        Exported Variables
        - stage.ai_documentation.GIT_TAG
        - stage.ai_documentation.GIT_COMMIT_SHA
      EOF
      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}
