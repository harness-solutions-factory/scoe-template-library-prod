locals {
  local_groups = flatten([
    for resource_file in fileset("${local.source_directory}/groups/", "*.yaml") : [
      merge(
        yamldecode(file("${local.source_directory}/groups/${resource_file}")),
        {
          identifier = replace(replace(replace(resource_file, ".yaml", ""), " ", "_"), "-", "_")
          name       = replace(replace(replace(resource_file, ".yaml", ""), "-", "_"), "_", " ")
        }
      )
    ]
  ])

  additional_groups = (
    var.additional_templates != null
    ?
    flatten([
      for resource_file in fileset("${var.additional_templates}/groups/", "*.yaml") : [
        merge(
          yamldecode(file("${var.additional_templates}/groups/${resource_file}")),
          {
            identifier = replace(replace(replace(resource_file, ".yaml", ""), " ", "_"), "-", "_")
            name       = replace(replace(replace(resource_file, ".yaml", ""), "-", "_"), "_", " ")
          }
        )
      ]
    ])
    :
    []
  )

  empty_notification_config = {
    slack     = {}
    msteams   = {}
    pagerduty = {}
    email     = {}
  }

  all_groups = flatten([
    for group_details in flatten([local.local_groups, local.additional_groups]) : [
      merge(
        group_details,
        {
          notification_configs = {
            for type in ["slack", "msteams", "pagerduty", "email"] :
            type => try(coalesce(var.group_notifications[group_details.identifier][type]), {})
          }
        }
      )
    ]
  ])

  groups = flatten([
    for group in local.all_groups : [
      group
    ] if !startswith(group.identifier, "_") && !startswith(group.identifier, "account_") && !startswith(group.identifier, "org_")
  ])

  existing_groups = flatten([
    for group in local.all_groups : [
      group
    ] if startswith(group.identifier, "_")
  ])

  existing_groups_account = flatten([
    for group in local.all_groups : [
      {
        identifier = replace(group.identifier, "account_", "")
      }
    ] if startswith(group.identifier, "account_")
  ])

  existing_groups_org = flatten([
    for group in local.all_groups : [
      {
        identifier = replace(group.identifier, "org_", "")
      }
    ] if startswith(group.identifier, "org_")
  ])

  groups_bindings = flatten([
    for group in local.all_groups : [
      for binding in lookup(group, "role_bindings", []) : {
        identifier       = "${group.identifier}_${lookup(binding, "role", "MISSING-ROLE-ID")}_${lookup(binding, "resource_group", "MISSING-RESOURCE-GROUP-ID")}"
        deprecated_id    = "${group.identifier}_${lookup(binding, "role", "MISSING-ROLE-ID")}"
        group_identifier = replace(replace(group.identifier, "account_", ""), "org_", "")
        group_name       = group.name
        role             = lookup(binding, "role", "MISSING-ROLE")
        resource_group   = lookup(binding, "resource_group", "MISSING-ROLE")

        scope_level = (
          startswith(group.identifier, "account_")
          ?
          "account"
          :
          startswith(group.identifier, "org_")
          ?
          "organization"
          :
          "project"
        )
      }
    ]
  ])
}

// Fetch existing account-level user groups (reference only)
data "harness_platform_usergroup" "account_usergroup" {
  for_each = {
    for group in local.existing_groups_account : group.identifier => group
  }
  identifier = each.value.identifier
}

// Fetch existing org-level user groups (reference only)
data "harness_platform_usergroup" "org_usergroup" {
  for_each = {
    for group in local.existing_groups_org : group.identifier => group
  }
  identifier = each.value.identifier
  org_id     = data.harness_platform_organization.selected.id
}

// Fetch existing project-level user groups (reference only)
data "harness_platform_usergroup" "usergroup" {
  for_each = {
    for group in local.existing_groups : group.identifier => group
  }
  identifier = each.value.identifier
  org_id     = data.harness_platform_organization.selected.id
  project_id = harness_platform_project.selected.id
}

// Create new user groups for HSF Hub project
resource "harness_platform_usergroup" "usergroup" {
  depends_on = [harness_platform_roles.role, harness_platform_resource_group.resource_group]
  lifecycle {
    ignore_changes = [
      users,
      user_emails,
      linked_sso_id,
      linked_sso_display_name,
      linked_sso_type,
      # notification_configs,
      sso_linked,
      sso_group_id,
      sso_group_name
    ]
  }
  for_each = {
    for group in local.groups : group.identifier => group
  }

  identifier  = each.value.identifier
  name        = each.value.name
  org_id      = data.harness_platform_organization.selected.id
  project_id  = harness_platform_project.selected.id
  description = lookup(each.value, "description", "Harness UserGroup managed by Solutions Factory")
  user_emails = []

  externally_managed      = false
  linked_sso_id           = lookup(each.value, "linked_sso_id", null)
  linked_sso_display_name = lookup(each.value, "linked_sso_id", null)
  linked_sso_type         = lookup(each.value, "linked_sso_type", null)
  sso_linked              = lookup(each.value, "sso_group_id", null) != null ? true : false
  sso_group_id            = lookup(each.value, "sso_group_id", null)
  sso_group_name          = lookup(each.value, "sso_group_id", null)

  dynamic "notification_configs" {
    for_each = lookup(lookup(each.value, "notification_configs", {}), "slack", {}) != {} ? [lookup(lookup(each.value, "notification_configs", {}), "slack", "")] : []
    content {
      type              = "SLACK"
      slack_webhook_url = lookup(notification_configs.value, "webhook", "MISSING-WEBHOOK")
    }
  }
  dynamic "notification_configs" {
    for_each = lookup(lookup(each.value, "notification_configs", {}), "msteams", {}) != {} ? [lookup(lookup(each.value, "notification_configs", {}), "msteams", {})] : []
    content {
      type                        = "MSTEAMS"
      microsoft_teams_webhook_url = lookup(notification_configs.value, "webhook", "MISSING-WEBHOOK")
    }
  }
  dynamic "notification_configs" {
    for_each = lookup(lookup(each.value, "notification_configs", {}), "pagerduty", {}) != {} ? [lookup(lookup(each.value, "notification_configs", {}), "pagerduty", {})] : []
    content {
      type           = "PAGERDUTY"
      pager_duty_key = lookup(notification_configs.value, "key", "MISSING-KEY")
    }
  }
  dynamic "notification_configs" {
    for_each = lookup(lookup(each.value, "notification_configs", {}), "email", {}) != {} ? [lookup(lookup(each.value, "notification_configs", {}), "email", {})] : []
    content {
      type                    = "EMAIL"
      group_email             = join(",", lookup(notification_configs.value, "group_email", []))
      send_email_to_all_users = lookup(notification_configs.value, "email_all", false)
    }
  }

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])
}

// Assign roles and permissions to user groups
resource "harness_platform_role_assignments" "usergroup_bindings" {
  depends_on = [harness_platform_usergroup.usergroup]
  for_each = {
    for group in local.groups_bindings : group.identifier => group
  }

  identifier                = each.value.identifier
  org_id                    = data.harness_platform_organization.selected.id
  project_id                = harness_platform_project.selected.id
  resource_group_identifier = each.value.resource_group
  role_identifier           = each.value.role

  principal {
    identifier = try(
      harness_platform_usergroup.usergroup[each.value.group_identifier].id,
      harness_platform_usergroup.usergroup[each.value.group_name].id,
      data.harness_platform_usergroup.usergroup[each.value.group_identifier].id,
      data.harness_platform_usergroup.org_usergroup[each.value.group_identifier].id,
      data.harness_platform_usergroup.account_usergroup[each.value.group_identifier].id
    )
    scope_level = each.value.scope_level
    type        = "USER_GROUP"
  }
  disabled = false
  managed  = false
}
