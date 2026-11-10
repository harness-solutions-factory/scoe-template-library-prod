output "organization_identifier" {
  description = "Organization Identifier"
  value       = module.harness_organization.organization_identifier
}

output "organization_url" {
  value = module.harness_organization.organization_url
}
