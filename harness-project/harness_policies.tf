locals {
  local_policies = flatten([
    for resource_file in fileset("${local.source_directory}/policies/", "*.yaml") : [
      merge(
        yamldecode(file("${local.source_directory}/policies/${resource_file}")),
        {
          identifier = replace(replace(replace(resource_file, ".yaml", ""), " ", "_"), "-", "_")
          name       = replace(replace(replace(resource_file, ".yaml", ""), "-", "_"), "_", " ")
        }
      )
    ]
  ])

  additional_policies = (
    var.additional_templates != null
    ?
    flatten([
    for resource_file in fileset("${var.additional_templates}/policies/", "*.yaml") : [
      merge(
        yamldecode(file("${var.additional_templates}/policies/${resource_file}")),
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

  all_policies = flatten([
    local.local_policies,
    local.additional_policies
  ])
}


resource "harness_platform_policy" "policies" {
  depends_on = [harness_time_sleep.project_setup]
  lifecycle {
    ignore_changes = [
      git_commit_msg,
      git_connector_ref,
      git_path,
      git_repo,
      git_branch,
      git_base_branch,
      git_is_new_branch,
      git_import
    ]
  }
  for_each = {
    for policy in local.all_policies : policy.identifier => policy
  }
  identifier  = each.value.identifier
  name        = each.value.name
  description = lookup(each.value, "description", "Harness Policy managed by Solutions Factory")
  rego        = each.value.payload

  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])
}
