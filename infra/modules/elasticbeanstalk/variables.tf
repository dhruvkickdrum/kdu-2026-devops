variable "app_name" {
  type        = string
  description = "Application name prefix."
}

variable "environment" {
  type        = string
  description = "Environment/workspace identifier."
}

variable "service_role_name" {
  type        = string
  description = "Elastic Beanstalk service role name."
}

variable "ec2_instance_profile_name" {
  type        = string
  description = "Elastic Beanstalk EC2 instance profile name."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}
