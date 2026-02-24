output "db_instance_id" {
  value       = aws_db_instance.this.id
  description = "RDS instance ID."
}

output "db_endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "RDS endpoint."
}

output "db_subnet_group_name" {
  value       = aws_db_subnet_group.this.name
  description = "DB subnet group name."
}
