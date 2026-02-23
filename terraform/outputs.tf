output "cloudfront_url" {
  description = "CloudFront distribution URL - use this to access your website"
  value       = "https://${module.website.cloudfront_domain}"
}

output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = module.api.api_endpoint
}

output "website_bucket" {
  description = "S3 website bucket name"
  value       = module.website.bucket_name
}

output "dynamodb_table" {
  description = "DynamoDB messages table name"
  value       = module.database.table_name
}