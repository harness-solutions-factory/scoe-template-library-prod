locals {
  local_resource_groups = flatten([
    for resource_file in fileset("${local.source_directory}/resource_groups/", "*.yaml") : [
      merge(
        yamldecode(file("${local.source_directory}/resource_groups/${resource_file}")),
        {
          identifier = replace(replace(replace(resource_file, ".yaml", ""), " ", "_"), "-", "_")
          name       = replace(replace(replace(resource_file, ".yaml", ""), "-", "_"), "_", " ")
        }
      )
    ]
  ])

  additional_resource_groups = (
    var.additional_templates != null
    ?
    flatten([
      for resource_file in fileset("${var.additional_templates}/resource_groups/", "*.yaml") : [
        merge(
          yamldecode(file("${var.additional_templates}/resource_groups/${resource_file}")),
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

  all_resource_groups = flatten([
    local.local_resource_groups,
    local.additional_resource_groups
  ])
}
resource "harness_platform_resource_group" "resource_group" {
  depends_on = [harness_time_sleep.project_setup]
  for_each = {
    for resource_group in local.all_resource_groups : resource_group.name => resource_group
  }

  identifier = replace(replace(each.value.name, " ", "_"), "-", "_")

  name        = each.value.name
  description = lookup(each.value, "description", "Harness ResourceGroup managed by Solutions Factory")
  account_id  = var.harness_platform_account
  org_id      = data.harness_platform_organization.selected.id
  project_id  = harness_platform_project.selected.id

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])

  allowed_scope_levels = ["project"]
  included_scopes {
    filter     = "EXCLUDING_CHILD_SCOPES"
    account_id = var.harness_platform_account
    org_id     = data.harness_platform_organization.selected.id
    project_id = harness_platform_project.selected.id
  }
  resource_filter {
    include_all_resources = lookup(each.value, "resource_filters", null) != null ? false : true
    dynamic "resources" {
      for_each = lookup(each.value, "resource_filters", [])
      content {
        resource_type = lookup(resources.value, "type", null)
        # (Set of String) List of the identifiers
        identifiers = lookup(resources.value, "identifiers", null)
        dynamic "attribute_filter" {
          for_each = lookup(resources.value, "filters", [])
          content {
            # (String) Name of the attribute
            attribute_name = lookup(attribute_filter.value, "name", null)
            # (Set of String) Value of the attributes
            attribute_values = flatten([lookup(attribute_filter.value, "values", [])])
          }
        }
      }
    }
  }
}
