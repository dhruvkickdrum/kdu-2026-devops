terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3_artifacts" {
  source      = "./modules/s3_artifacts"
  app_name    = var.app_name
  environment = var.environment
  tags        = local.common_tags
}

module "iam" {
  source      = "./modules/iam"
  app_name    = var.app_name
  environment = var.environment
  tags        = local.common_tags
}

module "elasticbeanstalk" {
  source                    = "./modules/elasticbeanstalk"
  app_name                  = var.app_name
  environment               = var.environment
  service_role_name         = module.iam.elastic_beanstalk_service_role_name
  ec2_instance_profile_name = module.iam.elastic_beanstalk_ec2_instance_profile_name
  tags                      = local.common_tags
}

module "codebuild" {
  source                 = "./modules/codebuild"
  app_name               = var.app_name
  environment            = var.environment
  codebuild_service_role = module.iam.codebuild_role_arn
  tags                   = local.common_tags
}
