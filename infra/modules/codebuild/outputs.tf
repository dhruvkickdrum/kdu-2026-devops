output "dev_project_name" {
  description = "Dev CodeBuild project name."
  value       = aws_codebuild_project.dev.name
}

output "prod_project_name" {
  description = "Prod CodeBuild project name."
  value       = aws_codebuild_project.prod.name
}

output "dev_project_arn" {
  description = "Dev CodeBuild project ARN."
  value       = aws_codebuild_project.dev.arn
}

output "prod_project_arn" {
  description = "Prod CodeBuild project ARN."
  value       = aws_codebuild_project.prod.arn
}
