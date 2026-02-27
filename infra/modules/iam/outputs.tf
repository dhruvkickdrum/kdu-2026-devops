output "codebuild_role_arn" {
  description = "IAM role ARN for CodeBuild projects."
  value       = aws_iam_role.codebuild.arn
}

output "codepipeline_role_arn" {
  description = "IAM role ARN for manual CodePipeline creation."
  value       = aws_iam_role.codepipeline.arn
}

output "elastic_beanstalk_service_role_name" {
  description = "Elastic Beanstalk service role name."
  value       = aws_iam_role.elastic_beanstalk_service.name
}

output "elastic_beanstalk_ec2_instance_profile_name" {
  description = "Elastic Beanstalk EC2 instance profile name."
  value       = aws_iam_instance_profile.elastic_beanstalk_ec2.name
}
