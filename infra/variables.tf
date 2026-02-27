variable "aws_region" {
  type        = string
  description = "AWS region for all resources."
  default     = "ap-northeast-3"
}

variable "app_name" {
  type        = string
  description = "Application name prefix for resources."
  default     = "dhruv-cicd"
}

variable "environment" {
  type        = string
  description = "Environment/workspace identifier used in names and tags."
  default     = "shared"
}
