variable "additional_tags" {
  default     = {}
  description = "Additional Environment specific tags merged into common_tags"
  type        = map(any)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "lifecycle_policy" {
  default     = null
  description = "Lifecycle policy rules to override standard ruleset"
  type        = object({ rules = list(any) })
}