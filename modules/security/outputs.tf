output "alb_sg_id" {
  value       = aws_security_group.alb.id
  description = "ALB security group ID."
}

output "app_sg_id" {
  value       = aws_security_group.app.id
  description = "Application security group ID."
}

output "db_sg_id" {
  value       = aws_security_group.db.id
  description = "Database security group ID."
}

output "bastion_sg_id" {
  value       = aws_security_group.bastion.id
  description = "Bastion security group ID."
}
