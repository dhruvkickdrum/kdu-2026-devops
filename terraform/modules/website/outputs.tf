output "cloudfront_domain" {
  value = aws_cloudfront_distribution.website.domain_name
}

output "bucket_name" {
  value = aws_s3_bucket.website.id
}