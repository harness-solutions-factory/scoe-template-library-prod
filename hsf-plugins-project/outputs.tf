output "organization_identifier" {
  description = "Organization Identifier"
  value       = module.harness_project.organization_identifier
}

output "project_identifier" {
  description = "Project Identifier"
  value       = module.harness_project.project_identifier
}

output "project_url" {
  value = module.harness_project.project_url
}
