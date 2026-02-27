output "artifact_bucket" {
  description = "S3 bucket used by CodePipeline for artifacts."
  value       = module.s3_artifacts.bucket_name
}

output "codepipeline_role_arn" {
  description = "Use this IAM role when creating CodePipeline manually in the console."
  value       = module.iam.codepipeline_role_arn
}

output "codebuild_dev_project" {
  description = "CodeBuild project for develop branch CI."
  value       = module.codebuild.dev_project_name
}

output "codebuild_prod_project" {
  description = "CodeBuild project for main branch CI."
  value       = module.codebuild.prod_project_name
}

output "eb_application_name" {
  description = "Elastic Beanstalk application name."
  value       = module.elasticbeanstalk.application_name
}

output "eb_dev_environment_name" {
  description = "Elastic Beanstalk dev environment name."
  value       = module.elasticbeanstalk.dev_environment_name
}

output "eb_prod_environment_name" {
  description = "Elastic Beanstalk prod environment name."
  value       = module.elasticbeanstalk.prod_environment_name
}

output "eb_dev_url" {
  description = "Elastic Beanstalk dev URL."
  value       = module.elasticbeanstalk.dev_endpoint_url
}

output "eb_prod_url" {
  description = "Elastic Beanstalk prod URL."
  value       = module.elasticbeanstalk.prod_endpoint_url
}
