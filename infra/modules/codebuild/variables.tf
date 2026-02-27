variable "app_name" {
  type        = string
  description = "Application name prefix."
}

variable "environment" {
  type        = string
  description = "Environment/workspace identifier."
}

variable "codebuild_service_role" {
  type        = string
  description = "IAM role ARN used by CodeBuild."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}
