provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_cidr           = var.vpc_cidr
  enable_nat_gateway = var.enable_nat_gateway
}

data "aws_caller_identity" "current" {}

module "lambda" {
  source = "./modules/lambda"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  aws_account_id     = data.aws_caller_identity.current.account_id
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  log_retention_days = var.log_retention_days
  base_url           = trimsuffix(module.api_gateway.api_endpoint, "/")
}

module "api_gateway" {
  source = "./modules/api_gateway"

  project_name                   = var.project_name
  environment                    = var.environment
  log_retention_days             = var.log_retention_days
  create_short_url_function_arn  = module.lambda.create_short_url_function_arn
  create_short_url_function_name = module.lambda.create_short_url_function_name
  redirect_function_arn          = module.lambda.redirect_function_arn
  redirect_function_name         = module.lambda.redirect_function_name
}
