variable "aws_region" {
  type        = string
  description = "AWS region for the deployment."
  default     = "us-west-2"
}

variable "prefname" {
  type        = string
  description = "Prefix used for resource naming and Creator tag."
  default     = "dhruv"
}

variable "environment" {
  type        = string
  description = "Environment tag value."
  default     = "dev"
}

variable "purpose" {
  type        = string
  description = "Purpose tag value."
  default     = "kdu-2026"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private application subnets."
  default     = ["10.0.11.0/24"]
}

variable "db_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for database subnets."
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "bastion_ssh_cidrs" {
  type        = list(string)
  description = "Allowed CIDR blocks for SSH access to the bastion host."
  default     = ["0.0.0.0/0"]
}

variable "db_name" {
  type        = string
  description = "Database name."
  default     = "dhruvdb"
}

variable "db_username" {
  type        = string
  description = "Master username for the database."
  default     = "dhruv"
}

variable "db_password" {
  type        = string
  description = "Master password for the database."
  default     = "dhruv12345!"
}

variable "private_key_path" {
  type        = string
  description = "Path to write the generated SSH private key."
  default     = ""
}

variable "app_instance_type" {
  type        = string
  description = "Instance type for compute resources."
  default     = "t3.micro"
}
