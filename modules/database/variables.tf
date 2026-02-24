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

variable "db_name" {
  type        = string
  description = "Database name."
}

variable "db_username" {
  type        = string
  description = "Master username for the database."
}

variable "db_password" {
  type        = string
  description = "Master password for the database."
  sensitive   = true
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "Database subnet IDs."
}

variable "db_sg_id" {
  type        = string
  description = "Database security group ID."
}
