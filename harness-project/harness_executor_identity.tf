//////////////
// Pipeline Executor Service Account for Project
//
// In order to ensure access to Account and Organization level resources, the service_account
// must be created at the account level
//////////////
resource "harness_platform_service_account" "hsf_executor_identity" {
  identifier  = "${local.project_scope_ref}_hsf_executor_identity"
  name        = "${local.project_scope_ref}_hsf_executor_identity"
  email       = "${local.project_scope_ref}_hsf_executor_identity@service.harness.io"
  description = "Default pipeline executor identity for the Project ${local.project_id} in Organization ${local.organization_id}"
  account_id  = var.harness_platform_account
  tags = local.common_tags_tuple
}

// Create API key container in master service account
resource "harness_platform_apikey" "hsf_executor_identity_api_key" {
  identifier                   = "platform_manager"
  name                         = "platform_manager"
  parent_id                    = harness_platform_service_account.hsf_executor_identity.id
  account_id                   = harness_platform_service_account.hsf_executor_identity.account_id
  apikey_type                  = "SERVICE_ACCOUNT"
  default_time_to_expire_token = 2592000000
  tags                         = local.common_tags_tuple
}

// Generate API token for master service account automation (expires Dec 31, 2099)
resource "harness_platform_token" "hsf_executor_identity_token" {
  identifier  = "automation"
  name        = "automation"
  parent_id   = harness_platform_apikey.hsf_executor_identity_api_key.parent_id
  apikey_type = harness_platform_apikey.hsf_executor_identity_api_key.apikey_type
  apikey_id   = harness_platform_apikey.hsf_executor_identity_api_key.id
  account_id  = harness_platform_apikey.hsf_executor_identity_api_key.account_id
  valid_to    = "4102380000000" // December 31, 2099
  tags        = local.common_tags_tuple
  lifecycle {
    ignore_changes = all
  }
}

// Store master service account token as a project-level secret (unmanaged to allow customer control)
resource "harness_platform_secret_text" "harness_platform_key" {
  depends_on = [harness_time_sleep.project_setup]
  identifier  = "hsf_executor_identity_api_key"
  name        = "HSF Executor API Key"
  description = "Harness Executor API Key"
  org_id      = local.organization_id
  project_id  = local.project_id
  tags = flatten([
    local.common_tags_tuple,
    ["required_for:hsf_executor_identity"]
  ])

  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = harness_platform_token.hsf_executor_identity_token.value
  lifecycle {
    ignore_changes = all
  }
}

// Create a new Account-level Resource Group scoped to this project
resource "harness_platform_resource_group" "hsf_executor_identity_resource_group" {
  # depends_on = [harness_time_sleep.project_setup]
  identifier = "${local.project_scope_ref}_hsf_executor_identity"

  name        = "${local.project_scope_ref}_hsf_executor_identity"
  description = "Project-scoped Resource Group designed to provide project level controls for service accounts."
  account_id  = var.harness_platform_account

  tags = flatten([
    local.common_tags_tuple,
    ["required_for:hsf_executor_identity"]
  ])

  allowed_scope_levels = ["account"]
  included_scopes {
    filter     = "EXCLUDING_CHILD_SCOPES"
    account_id = var.harness_platform_account
    org_id = local.organization_id
    project_id = local.project_id
  }
  resource_filter {
    include_all_resources = true
  }
}

locals {
  account_executor_roles = [
    "Shared_Resource_Access",
    "_artifact_registry_contributor"
  ]
  org_executor_roles = [
    "_llm_gateway_user",
    "Shared_Resource_Access"
  ]
  project_executor_roles = [
    "Pipeline_Executor",
    "_code_contributor"
  ]
}

// Grant the service account account-level roles
resource "harness_platform_role_assignments" "hsf_executor_identity__account_role_assignements" {
  for_each = {
    for role_name in local.account_executor_roles : role_name => role_name
  }
  identifier                = "${harness_platform_service_account.hsf_executor_identity.id}_account_${each.value}"
  resource_group_identifier = "_all_account_level_resources"
  role_identifier           = each.value
  principal {
    identifier = harness_platform_service_account.hsf_executor_identity.id
    type       = "SERVICE_ACCOUNT"
    scope_level = "account"
  }
  disabled = false
  managed  = false
}
// Grant the service account organization-level roles
resource "harness_platform_role_assignments" "hsf_executor_identity__org_role_assignements" {
  for_each = {
    for role_name in local.org_executor_roles : role_name => role_name
  }
  identifier                = "${harness_platform_service_account.hsf_executor_identity.id}_org_${each.value}"
  resource_group_identifier = "${lower(local.organization_id)}_hsf_executor_identity"
  role_identifier           = each.value
  principal {
    identifier = harness_platform_service_account.hsf_executor_identity.id
    type       = "SERVICE_ACCOUNT"
    scope_level = "account"
  }
  disabled = false
  managed  = false
}
// Grant the service account project-level roles
resource "harness_platform_role_assignments" "hsf_executor_identity_project_role_assignements" {
  for_each = {
    for role_name in local.project_executor_roles : role_name => role_name
  }
  identifier                = "${harness_platform_service_account.hsf_executor_identity.id}_project_${each.value}"
  resource_group_identifier = harness_platform_resource_group.hsf_executor_identity_resource_group.id
  role_identifier           = each.value
  principal {
    identifier = harness_platform_service_account.hsf_executor_identity.id
    type       = "SERVICE_ACCOUNT"
    scope_level = "account"
  }
  disabled = false
  managed  = false
}

# TODO: This is blocked - 2026-10-27
# resource "harness_platform_setting" "hsf_executor_identity" {
#   identifier = "enforce_executor_identity_for_triggers"
#   org_id      = harness_platform_apikey.hsf_executor_identity_api_key.org_id
#   project_id  = harness_platform_apikey.hsf_executor_identity_api_key.project_id
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

      TOKEN_OWNER_REF : harness_platform_apikey.hsf_executor_identity_api_key.parent_id
      TOKEN_API_KEY_REF : harness_platform_apikey.hsf_executor_identity_api_key.id
      TOKEN_ORG_ID : coalesce(harness_platform_apikey.hsf_executor_identity_api_key.org_id, "skipped")
      TOKEN_PROJECT_ID : coalesce(harness_platform_apikey.hsf_executor_identity_api_key.project_id, "skipped")
      SECRET_ID : harness_platform_secret_text.harness_platform_key.id
      SECRET_ORG_ID : coalesce(harness_platform_secret_text.harness_platform_key.org_id, "skipped")
      SECRET_PROJECT_ID : coalesce(harness_platform_secret_text.harness_platform_key.project_id, "skipped")
      UPDATE_SELF : "false"

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}
