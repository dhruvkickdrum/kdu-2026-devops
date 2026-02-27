resource "aws_elastic_beanstalk_application" "app" {
  name        = var.app_name
  description = "Spring Boot application deployed through CodePipeline."
  tags        = var.tags
}

data "aws_elastic_beanstalk_solution_stack" "java" {
  most_recent = true
  name_regex  = "64bit Amazon Linux.*Corretto 17.*"
}

locals {
  common_settings = [
    {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "EnvironmentType"
      value     = "LoadBalanced"
    },
    {
      namespace = "aws:elasticbeanstalk:healthreporting:system"
      name      = "SystemType"
      value     = "enhanced"
    },
    {
      namespace = "aws:elasticbeanstalk:command"
      name      = "DeploymentPolicy"
      value     = "Rolling"
    },
    {
      namespace = "aws:elasticbeanstalk:command"
      name      = "BatchSizeType"
      value     = "Percentage"
    },
    {
      namespace = "aws:elasticbeanstalk:command"
      name      = "BatchSize"
      value     = "30"
    },
    {
      namespace = "aws:elasticbeanstalk:environment"
      name      = "ServiceRole"
      value     = var.service_role_name
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = var.ec2_instance_profile_name
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "InstanceType"
      value     = "t3.small"
    },
    {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "StreamLogs"
      value     = "true"
    },
    {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "DeleteOnTerminate"
      value     = "false"
    }
  ]
}

resource "aws_elastic_beanstalk_environment" "dev" {
  name                = "${var.app_name}-${var.environment}-dev"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.java.name
  tags                = var.tags

  dynamic "setting" {
    for_each = local.common_settings
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
    }
  }
}

resource "aws_elastic_beanstalk_environment" "prod" {
  name                = "${var.app_name}-${var.environment}-prod"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.java.name
  tags                = var.tags

  dynamic "setting" {
    for_each = local.common_settings
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
    }
  }
}
