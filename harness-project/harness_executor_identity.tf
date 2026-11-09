resource "harness_platform_service_account" "pipeline_executor" {
  identifier  = "hsf_executor_identity"
  name        = "hsf_executor_identity"
  email       = "hsf_executor_identity@service.harness.io"
  description = "Default pipeline executor identity"
  account_id  = var.harness_platform_account
  org_id      = data.harness_platform_organization.selected.id
  project_id  = harness_platform_project.selected.id
  tags = local.common_tags_tuple
}

// Create API key container in master service account
resource "harness_platform_apikey" "platform_manager" {
  identifier                   = "platform_manager"
  name                         = "platform_manager"
  parent_id                    = harness_platform_service_account.pipeline_executor.id
  account_id                   = harness_platform_service_account.pipeline_executor.account_id
  org_id      = harness_platform_service_account.pipeline_executor.org_id
  project_id  = harness_platform_service_account.pipeline_executor.project_id
  apikey_type                  = "SERVICE_ACCOUNT"
  default_time_to_expire_token = 2592000000
  tags                         = local.common_tags_tuple
}

// Generate API token for master service account automation (expires Dec 31, 2099)
resource "harness_platform_token" "platform_manager" {
  identifier  = "automation"
  name        = "automation"
  parent_id   = harness_platform_apikey.platform_manager.parent_id
  apikey_type = harness_platform_apikey.platform_manager.apikey_type
  apikey_id   = harness_platform_apikey.platform_manager.id
  account_id  = harness_platform_apikey.platform_manager.account_id
  org_id      = harness_platform_apikey.platform_manager.org_id
  project_id  = harness_platform_apikey.platform_manager.project_id
  valid_to    = "4102380000000" // December 31, 2099
  tags        = local.common_tags_tuple
  lifecycle {
    ignore_changes = all
  }
}

// Grant the service account project-level LLM Gateway Access
resource "harness_platform_role_assignments" "hsf_executor_identity_llm_gateway_access" {
  identifier                = "${harness_platform_service_account.pipeline_executor.id}_${harness_platform_roles.role["LLM_Worker_Access"].id}"
  org_id      = harness_platform_apikey.platform_manager.org_id
  project_id  = harness_platform_apikey.platform_manager.project_id
  resource_group_identifier = "_all_project_level_resources"
  role_identifier           = harness_platform_roles.role["LLM_Worker_Access"].id
  principal {
    identifier = harness_platform_service_account.pipeline_executor.id
    type       = "SERVICE_ACCOUNT"
    scope_level = "project"
  }
  disabled = false
  managed  = false
}
// Grant the service account project-level Pipeline Executor Access
resource "harness_platform_role_assignments" "hsf_executor_identity_pipeline_executor_access" {
  identifier                = "${harness_platform_service_account.pipeline_executor.id}_pipeline_executor"
  org_id      = harness_platform_apikey.platform_manager.org_id
  project_id  = harness_platform_apikey.platform_manager.project_id
  resource_group_identifier = "_all_project_level_resources"
  role_identifier           = "_pipeline_executor"
  principal {
    identifier = harness_platform_service_account.pipeline_executor.id
    type       = "SERVICE_ACCOUNT"
    scope_level = "project"
  }
  disabled = false
  managed  = false
}

// Store master service account token as a project-level secret (unmanaged to allow customer control)
resource "harness_platform_secret_text" "harness_platform_key" {
  identifier  = "hsf_executor_identity_api_key"
  name        = "HSF Executor API Key"
  description = "Harness Executor API Key"
  org_id      = harness_platform_apikey.platform_manager.org_id
  project_id  = harness_platform_apikey.platform_manager.project_id
  tags = flatten([
    local.common_tags_tuple,
    ["required_for:hsf_executor_identity"]
  ])

  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = harness_platform_token.platform_manager.value
  lifecycle {
    ignore_changes = all
  }
}

# TODO: This is blocked - 2026-10-27
# resource "harness_platform_setting" "hsf_executor_identity" {
#   identifier = "enforce_executor_identity_for_triggers"
#   org_id      = harness_platform_apikey.platform_manager.org_id
#   project_id  = harness_platform_apikey.platform_manager.project_id
#   value      = "true"
# }

resource "harness_platform_triggers" "hsf_executor_identity_rotate_token" {
  identifier  = "${harness_platform_project.selected.id}_hsf_executor_identity"
  name        = "${harness_platform_project.selected.id}_hsf_executor_identity"
  target_id   = "Rotate_Harness_Service_Account_Token_and_Secret"
  org_id      = "Harness_Platform_Management"
  project_id  = "Solutions_Factory"
  description = "Rotate the 'hsf_executor_identity' service account token in ${harness_platform_project.selected.id}"
  yaml = templatefile(
    "${path.module}/templates/pipelines/triggers/hsf_executor_identity_rotate_token.yaml",
    {
      # Trigger Setup Details
      TRIGGER_IDENTIFIER : "${harness_platform_project.selected.id}_hsf_executor_identity"
      TRIGGER_NAME : "${harness_platform_project.selected.id}_hsf_executor_identity"
      PIPELINE_IDENTIFIER : "Rotate_Harness_Service_Account_Token_and_Secret"
      ORGANIZATION_ID : "Harness_Platform_Management"
      PROJECT_ID : "Solutions_Factory"
      DESCRIPTION : "Rotate the 'hsf_executor_identity' service account token in ${harness_platform_project.selected.id}"

      CRON_TAB : "0 5 * * 0"

      TOKEN_OWNER_REF : harness_platform_apikey.platform_manager.parent_id
      TOKEN_API_KEY_REF : harness_platform_apikey.platform_manager.id
      TOKEN_ORG_ID : harness_platform_apikey.platform_manager.org_id
      TOKEN_PROJECT_ID : harness_platform_apikey.platform_manager.project_id
      SECRET_ID : harness_platform_secret_text.harness_platform_key.id
      SECRET_ORG_ID : harness_platform_secret_text.harness_platform_key.org_id
      SECRET_PROJECT_ID : harness_platform_secret_text.harness_platform_key.project_id
      UPDATE_SELF : "false"

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}
