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

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private application subnets."
}

variable "db_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for database subnets."
}
