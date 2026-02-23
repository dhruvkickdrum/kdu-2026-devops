terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    random = {                        
      source  = "hashicorp/random"    
      version = "~> 3.0"             
    } 
  }
}

provider "aws" {
  region = var.aws_region
}

module "database" {
  source       = "./modules/database"
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "api" {
  source         = "./modules/api"
  project_name   = var.project_name
  environment    = var.environment
  dynamodb_table = module.database.table_name
  dynamodb_arn   = module.database.table_arn
  aws_region     = var.aws_region
  tags           = var.tags
}

module "website" {
  source           = "./modules/website"
  project_name     = var.project_name
  environment      = var.environment
  tags             = var.tags
}