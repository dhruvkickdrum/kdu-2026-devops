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

variable "alb_sg_id" {
  type        = string
  description = "ALB security group ID."
}

variable "asg_name" {
  type        = string
  description = "Auto Scaling Group name to attach to target groups."
}
