output "application_name" {
  description = "Elastic Beanstalk application name."
  value       = aws_elastic_beanstalk_application.app.name
}

output "dev_environment_name" {
  description = "Dev environment name."
  value       = aws_elastic_beanstalk_environment.dev.name
}

output "prod_environment_name" {
  description = "Prod environment name."
  value       = aws_elastic_beanstalk_environment.prod.name
}

output "dev_endpoint_url" {
  description = "Dev endpoint URL."
  value       = aws_elastic_beanstalk_environment.dev.endpoint_url
}

output "prod_endpoint_url" {
  description = "Prod endpoint URL."
  value       = aws_elastic_beanstalk_environment.prod.endpoint_url
}

output "eb_solution_stack_used" {
  value = data.aws_elastic_beanstalk_solution_stack.java.name
}
