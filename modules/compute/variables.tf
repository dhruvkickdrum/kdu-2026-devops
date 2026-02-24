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
  description = "VPC ID."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs."
}

variable "private_app_subnet_ids" {
  type        = list(string)
  description = "Private application subnet IDs."
}

variable "bastion_sg_id" {
  type        = string
  description = "Bastion security group ID."
}

variable "app_sg_id" {
  type        = string
  description = "Application security group ID."
}

variable "db_endpoint" {
  type        = string
  description = "Database endpoint."
}

variable "db_name" {
  type        = string
  description = "Database name."
}

variable "db_username" {
  type        = string
  description = "Database username."
}

variable "db_password" {
  type        = string
  description = "Database password."
  sensitive   = true
}

variable "private_key_path" {
  type        = string
  description = "Path to write the generated SSH private key. Leave empty to use module path."
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "Instance type for compute resources."
  default     = "t3.micro"
}
