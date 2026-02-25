output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID."
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnet IDs."
}

output "private_app_subnet_ids" {
  value       = [aws_subnet.private_app.id]
  description = "Private application subnet IDs."
}

output "db_subnet_ids" {
  value       = aws_subnet.db[*].id
  description = "Database subnet IDs."
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.this.id
  description = "Internet gateway ID."
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.this.id
  description = "NAT gateway ID."
}
