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

variable "organization_id" {
  type        = string
  description = "[Required] Provide an organization reference ID.  Must exist before execution"
}

variable "project_id" {
  type        = string
  description = "[Optional] New Project Identifier. If not provided, then the project_name will be formatted to replace spaces and dashes with underscores"
  default     = null
}

variable "project_name" {
  type        = string
  description = "[Required] New Project Name"
}

variable "project_description" {
  type        = string
  description = "[Optional] New Project Description"
  default     = "Harness Project managed by Solutions Factory"
}

variable "tags" {
  type        = map(any)
  description = "[Optional] Provide a Map of Tags to associate with the resources"
  default     = {}
}

variable "additional_templates" {
  type        = string
  description = "Provide an absolute path to an additional template directory"
  default     = null
}

variable "group_notifications" {
  type = map(object({
    slack     = optional(object({ webhook = string }))
    msteams   = optional(object({ webhook = string }))
    pagerduty = optional(object({ key = string }))
    email = optional(object({
      group_email = optional(list(string), [])
      email_all   = bool
    }))
  }))
  description = "Provide a map where each key is the 'group.identifer' and the value is a map of keys"
  default     = {}
}
