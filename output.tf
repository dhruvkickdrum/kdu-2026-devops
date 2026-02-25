output "alb_dns_name" {
  value       = module.load_balancer.alb_dns_name
  description = "ALB DNS name."
}

output "bastion_public_ip" {
  value       = module.compute.bastion_public_ip
  description = "Bastion public IP."
}

output "ssh_private_key_path" {
  value       = module.compute.ssh_private_key_path
  description = "Path to generated SSH private key."
}

output "db_endpoint" {
  value       = module.database.db_endpoint
  description = "RDS endpoint."
}
