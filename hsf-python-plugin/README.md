# Harness Solutions Factory - Python Application Plugin

Automated onboarding and CI/CD pipeline setup for Python applications with integrated security scanning, build automation, and artifact publishing.

## Summary

This template creates a complete CI/CD workflow for Python applications within Harness. It automates the setup of repositories, pipelines, and triggers to enable continuous integration with security scanning (SAST/SCA), build processes, and Docker image publishing.

This Template creates the following resources:
- Harness Repository for source code management
- Harness Pipeline with Python application build and test stages
- Automated triggers for push events, pull requests, branch creation, and releases
- Integrated SAST/SCA security scanning using industry-standard tools
- Docker image build and publishing to container registries


## Providers

This template is designed to be used as a Terraform Module and requires the Harness provider to manage platform resources. The Harness provider configuration is defined in the [Harness Provider Documentation](https://registry.terraform.io/providers/harness/harness/latest/docs).

A `providers.tf` file is included as a reference for configuring your Harness provider credentials. When using this template:
- Ensure the Harness provider is configured with your account credentials
- The provider configuration should include your Harness API endpoint and authentication token
- All resources created by this template are managed through the Harness provider

### Terraform Required Providers

```hcl
terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    harness = {
      source  = "harness/harness"
      version = ">= 0.45"
    }
  }
}
```

## Requirements

The following items must be preconfigured in the target Harness Account:
- Active Harness Account with Organization and Project setup
- Harness API Key with appropriate permissions for creating pipelines, repositories, and triggers
- [Optional] Docker registry credentials for publishing container images (DockerHub, Artifact Repository, etc.)
- [Optional] Source control provider connector (GitHub, GitLab, Bitbucket, etc.) if integrating external repositories

## Variables

| Name | Required | Description | Type | Default |
| --- | --- | --- | --- | --- |
| harness_platform_url | | Harness Platform URL | string | `https://app.harness.io/gateway` |
| harness_platform_account | ✓ | Harness Account ID | string | — |
| organization_id | ✓ | Organization ID where the pipeline will be created | string | — |
| project_id | ✓ | Project ID where the pipeline will be created | string | — |
| pipeline_id | | Pipeline identifier (auto-generated from pipeline_name if not provided) | string | `null` |
| pipeline_name | ✓ | Display name for the pipeline | string | — |
| repository_name | ✓ | Repository name for the codebase | string | — |
| repository_description | | Description for the repository | string | `Sandbox Repository` |
| tags | | Tags to associate with created resources | map(any) | `{}` |


## Configuration Example

Create a `terraform.tfvars` file with the following structure:

```hcl
harness_platform_account = "YOUR_ACCOUNT_ID"
organization_id          = "default"
project_id               = "my_project"
pipeline_name            = "Python Application Pipeline"
repository_name          = "my-python-app"
repository_description   = "Python application repository for CI/CD"

tags = {
  environment = "production"
  team        = "platform"
  project     = "hsf"
}
```

## Pipeline Features

The generated pipeline includes the following stages and capabilities:

- **SAST Scans**: Security scanning using industry-standard tools (OWASP, Gitleaks, OSV)
- **Build**: Compilation and testing of the Python application
- **Publish**: Docker image creation and publishing to container registries

## Triggers

The template configures the following automated triggers:

- **Push Trigger**: Executes pipeline on commits to main branches
- **Pull Request Trigger**: Runs security and build checks on pull requests
- **Branch Creation Trigger**: Initializes pipelines when new branches are created
- **Release Trigger**: Automated deployment workflows on tagged releases

## Outputs

This template creates the following Harness resources that can be referenced by downstream workflows:

- **Pipeline**: Harness pipeline configured for Python application CI/CD
- **Repository**: Harness repository for managing source code
- **Triggers**: Automated triggers for various git events
- **Security Templates**: References to account-level security scanning templates

## Contributing

A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors

Module is maintained by Harness, Inc

## License

MIT License. See [LICENSE](../LICENSE) for full details.
