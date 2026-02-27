resource "aws_cloudwatch_log_group" "dev" {
  name              = "/aws/codebuild/${var.app_name}-${var.environment}-dev"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "prod" {
  name              = "/aws/codebuild/${var.app_name}-${var.environment}-prod"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_codebuild_project" "dev" {
  name         = "${var.app_name}-${var.environment}-dev-build"
  service_role = var.codebuild_service_role

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "cicdapp/buildspec.yml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.dev.name
      stream_name = "build"
      status      = "ENABLED"
    }
  }

  build_timeout  = 20
  queued_timeout = 60
  tags           = var.tags
}

resource "aws_codebuild_project" "prod" {
  name         = "${var.app_name}-${var.environment}-prod-build"
  service_role = var.codebuild_service_role

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "cicdapp/buildspec.yml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.prod.name
      stream_name = "build"
      status      = "ENABLED"
    }
  }

  build_timeout  = 20
  queued_timeout = 60
  tags           = var.tags
}
