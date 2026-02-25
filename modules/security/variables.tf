variable "prefname" {
  type        = string
  description = "Prefix used for resource naming and Creator tag."
}

variable "environment" {
  type        = string
  description = "Environment tag value."
}

variable "purpose" {
  type        = string
  description = "Purpose tag value."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security groups."
}

variable "bastion_ssh_cidrs" {
  type        = list(string)
  description = "Allowed CIDR blocks for SSH access to the bastion host."
}
