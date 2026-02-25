output "alb_arn" {
  value       = aws_lb.app.arn
  description = "ALB ARN."
}

output "alb_dns_name" {
  value       = aws_lb.app.dns_name
  description = "ALB DNS name."
}

output "backend_target_group_arn" {
  value       = aws_lb_target_group.backend.arn
  description = "Backend target group ARN."
}

output "frontend_target_group_arn" {
  value       = aws_lb_target_group.frontend.arn
  description = "Frontend target group ARN."
}
