variable "project_name" { type = string }
variable "environment"  { type = string }
variable "dynamodb_table" { type = string }
variable "dynamodb_arn"   { type = string }
variable "aws_region"     { type = string }
variable "tags"           { type = map(string) }