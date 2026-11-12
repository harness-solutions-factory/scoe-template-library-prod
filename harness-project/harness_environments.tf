locals {
  local_environments = flatten([
    for resource_file in fileset("${local.source_directory}/environments/", "*.yaml") : [
      merge(
        yamldecode(file("${local.source_directory}/environments/${resource_file}")),
        {
          identifier = replace(replace(replace(resource_file, ".yaml", ""), " ", "_"), "-", "_")
          name       = replace(replace(replace(resource_file, ".yaml", ""), "-", "_"), "_", " ")
        }
      )
    ]
  ])

  additional_environments = (
    var.additional_templates != null
    ?
    flatten([
    for resource_file in fileset("${var.additional_templates}/environments/", "*.yaml") : [
      merge(
        yamldecode(file("${var.additional_templates}/environments/${resource_file}")),
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

  environments = flatten([
    local.local_environments,
    local.additional_environments
  ])

  environments_bindings = flatten([
    for environment in local.environments : [
      for binding in lookup(environment, "role_bindings", []) : {
        identifier             = "${environment.identifier}_${lookup(binding, "role", "MISSING-ROLE-ID")}"
        environment_identifier = environment.identifier
        role                   = lookup(binding, "role", "MISSING-ROLE")
        resource_environment   = lookup(binding, "resource_environment", "MISSING-ROLE")
      }
    ]

  ])
}

resource "harness_platform_environment" "environments" {
  depends_on = [harness_time_sleep.project_setup]
  for_each = {
    for environment in local.environments : environment.name => environment
  }

  identifier = replace(replace(each.value.name, " ", "_"), "-", "_")

  name        = each.value.name
  org_id      = data.harness_platform_organization.selected.id
  project_id  = harness_platform_project.selected.id
  type        = lookup(each.value, "type", "PreProduction")
  description = lookup(each.value, "description", "Harness Environment managed by Solutions Factory")
  tags = flatten([
    [for k, v in lookup(each.value, "tags", {}) : "${k}:${v}"],
    local.common_tags_tuple
  ])

  yaml = lookup(each.value, "yaml", {}) != {} ? yamlencode(each.value.yaml) : null
}
