# Harness Account Setup
variable "harness_platform_url" {
  type        = string
  description = "[Optional] Enter the Harness Platform URL.  Defaults to Harness SaaS URL"
  default     = "https://app.harness.io/gateway"
}

variable "harness_platform_account" {
  type        = string
  description = "[Required] Enter the Harness Platform Account Number"
}

variable "tags" {
  type        = map(any)
  description = "[Optional] Provide a Map of Tags to associate with the resources"
  default     = {}
}

variable "organization_id" {
  type        = string
  description = "The Organization ID where the pipeline will be created"

  validation {
    # can() returns true if regex finds a match, or false if it throws an error
    condition     = can(regex("^[a-zA-Z][_a-zA-Z0-9]{2,128}$", var.organization_id))
    error_message = "Should not exceed 128 characters and must be unique within the Account"
  }
}

variable "project_id" {
  type        = string
  description = "The Project ID where the pipeline will be created"
  validation {
    # can() returns true if regex finds a match, or false if it throws an error
    condition     = can(regex("^[a-zA-Z][_a-zA-Z0-9]{2,128}$", var.project_id))
    error_message = "Should not exceed 128 characters and must be unique within the Organization"
  }
}

variable "pipeline_id" {
  type        = string
  description = "[Optional] Provide the Harness Pipeline Identifier"
  default     = null

  validation {
    # can() returns true if regex finds a match, or false if it throws an error
    condition = (
      var.pipeline_id != null
      ?
      can(regex("^[a-zA-Z][_a-zA-Z0-9]{2,128}$", var.pipeline_id))
      :
      true
    )
    error_message = "Should not exceed 128 characters and must be unique within the Project"
  }
}

variable "pipeline_name" {
  type        = string
  description = "[Required] Provide the Harness Pipeline Name"

  validation {
    # can() returns true if regex finds a match, or false if it throws an error
    condition     = can(regex("^[a-zA-Z][_\\-\\ a-zA-Z0-9]{2,128}$", var.pipeline_name))
    error_message = "Should not exceed 128 characters"
  }
}

variable "repository_name" {
  type        = string
  description = "[Required] Provide the Harness Repository Name"

  validation {
    # can() returns true if regex finds a match, or false if it throws an error
    condition     = can(regex("^[a-zA-Z][\\-a-zA-Z0-9]{2,128}$", var.repository_name))
    error_message = "Should not exceed 128 characters"
  }
}

variable "repository_description" {
  type        = string
  description = "Provide the Description for the Repository"
  default     = "Sandbox Repository"
}
