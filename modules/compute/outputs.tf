output "bastion_instance_id" {
  value       = aws_instance.bastion.id
  description = "Bastion instance ID."
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Bastion public IP."
}

output "autoscaling_group_name" {
  value       = aws_autoscaling_group.app.name
  description = "Application Auto Scaling Group name."
}

output "ssh_private_key_path" {
  value       = local.private_key_output
  description = "Path to the generated SSH private key."
}
