variable "app_name" {
  type        = string
  description = "Application name prefix."
}

variable "environment" {
  type        = string
  description = "Environment/workspace identifier."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}
