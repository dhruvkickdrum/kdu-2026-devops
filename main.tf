provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  prefname                 = var.prefname
  environment              = var.environment
  purpose                  = var.purpose
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  db_subnet_cidrs           = var.db_subnet_cidrs
}

module "security" {
  source = "./modules/security"

  prefname          = var.prefname
  environment       = var.environment
  purpose           = var.purpose
  vpc_id            = module.vpc.vpc_id
  bastion_ssh_cidrs = var.bastion_ssh_cidrs
}

module "database" {
  source = "./modules/database"

  prefname        = var.prefname
  environment     = var.environment
  purpose         = var.purpose
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
  db_subnet_ids   = module.vpc.db_subnet_ids
  db_sg_id        = module.security.db_sg_id
}

module "compute" {
  source = "./modules/compute"

  prefname                = var.prefname
  environment             = var.environment
  purpose                 = var.purpose
  vpc_id                  = module.vpc.vpc_id
  public_subnet_ids        = module.vpc.public_subnet_ids
  private_app_subnet_ids   = module.vpc.private_app_subnet_ids
  bastion_sg_id           = module.security.bastion_sg_id
  app_sg_id               = module.security.app_sg_id
  db_endpoint             = module.database.db_endpoint
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  private_key_path        = var.private_key_path
  instance_type           = var.app_instance_type
}

module "load_balancer" {
  source = "./modules/load_balancer"

  prefname          = var.prefname
  environment       = var.environment
  purpose           = var.purpose
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  asg_name          = module.compute.autoscaling_group_name
}
