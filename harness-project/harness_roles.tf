locals {
  local_roles = flatten([
    for resource_file in fileset("${local.source_directory}/roles/", "*.yaml") : [
      merge(
        yamldecode(file("${local.source_directory}/roles/${resource_file}")),
        {
          identifier = replace(replace(replace(resource_file, ".yaml", ""), " ", "_"), "-", "_")
          name       = replace(replace(replace(resource_file, ".yaml", ""), "-", "_"), "_", " ")
        }
      )
    ]
  ])

  additional_roles = (
    var.additional_templates != null
    ?
    flatten([
    for resource_file in fileset("${var.additional_templates}/roles/", "*.yaml") : [
      merge(
        yamldecode(file("${var.additional_templates}/roles/${resource_file}")),
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

  roles = flatten([
    local.local_roles,
    local.additional_roles
  ])

  # Valid list of allowed permission statuses
  permission_statuses = [
    "ACTIVE",
    "EXPERIMENTAL"
  ]

  # Generate Local list of all permissions in this scope
  project_permission_identifiers = sort(compact(flatten([
    for permission in data.harness_platform_permissions.current.permissions : [
      permission.identifier
    ] if contains(local.permission_statuses, permission.status) && contains(permission.allowed_scope_levels, "project")
  ])))

  # This object will contain keys based on the role name and the value of invalid permissions
  invalid_project_permissions = merge({
    for role in local.roles :
    (role.identifier) => flatten([
      for permission in role.permissions : [
        permission
      ] if !contains(local.project_permission_identifiers, permission)
    ])
  })
}

resource "harness_platform_roles" "role" {
  depends_on = [harness_time_sleep.project_setup]
  for_each = {
    for role in local.roles : role.identifier => role
  }
  # Lifecycle hook to prevent errors in planning due to invalid permission sets
  lifecycle {
    precondition {
      condition     = length(local.invalid_project_permissions[each.key]) == 0
      error_message = <<EOF
      [Invalid] The following permissions are invalid for this role - ${each.key}.
      - ${join("\n      - ", local.invalid_project_permissions[each.key])}
      EOF
    }
  }

  identifier = each.value.identifier

  name                 = each.value.name
  org_id               = data.harness_platform_organization.selected.id
  project_id           = harness_platform_project.selected.id
  allowed_scope_levels = ["project"]

  # [Optional] (Set of String) List of the permission identifiers
  #
  # Note: Full list of current and valid permissions can be found here
  # https://app.harness.io/gateway/authz/api/permissions
  # API Docs - https://apidocs.harness.io/tag/Permissions#operation/getPermissionList
  permissions = each.value.permissions

  tags = local.common_tags_tuple

}
