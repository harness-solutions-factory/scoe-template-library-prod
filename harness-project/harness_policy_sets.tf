locals {
  local_policy_sets = flatten([
    for resource_file in fileset("${local.source_directory}/policy_sets/", "*.yaml") : [
      merge(
        yamldecode(file("${local.source_directory}/policy_sets/${resource_file}")),
        {
          identifier = replace(replace(replace(resource_file, ".yaml", ""), " ", "_"), "-", "_")
          name       = replace(replace(replace(resource_file, ".yaml", ""), "-", "_"), "_", " ")
        }
      )
    ]
  ])

  additional_policy_sets = (
    var.additional_templates != null
    ?
    flatten([
    for resource_file in fileset("${var.additional_templates}/policy_sets/", "*.yaml") : [
      merge(
        yamldecode(file("${var.additional_templates}/policy_sets/${resource_file}")),
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

  all_policy_sets = flatten([
    local.local_policy_sets,
    local.additional_policy_sets
  ])
}
resource "harness_platform_policyset" "policy_sets" {
  depends_on = [harness_time_sleep.project_setup]
  for_each = {
    for policy_set in local.all_policy_sets : policy_set.identifier => policy_set
  }
  # Lifecycle hook to prevent errors in planning due to missing variables
  lifecycle {
    precondition {
      condition = alltrue([
        contains(keys(each.value), "identifier"),
        contains(keys(each.value), "name"),
        contains(keys(each.value), "action"),
        contains(keys(each.value), "type"),
        contains(["onrun", "onsave", "onstep"], lookup(each.value, "action", "missing-action"))
      ])
      error_message = <<EOF
      [Invalid] The following PolicySet (${each.key}) is invalid and missing one or more manadatory keys.
      - identifier
      - name
      - action
      - type

      Supported Action types are (depends on Policy Set type):
      - onrun
      - onsave
      - onstep
      EOF
    }
  }
  identifier = each.value.identifier
  name       = each.value.name
  action     = each.value.action
  type       = each.value.type
  enabled    = lookup(each.value, "enabled", true)

  dynamic "policy_references" {
    for_each = lookup(each.value, "policy_sets", [])
    content {
      identifier = policy_references.value["identifier"]
      severity   = lookup(policy_references.value, "severity", "error")
    }
  }

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])
}
