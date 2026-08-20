# environments/global/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# 1. Shared Network
module "vpc" {
  source               = "../../modules/vpc"
  environment          = "global"
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  public_subnets       = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_app_subnets  = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
  private_data_subnets = ["10.0.128.0/22", "10.0.132.0/22", "10.0.136.0/22"]
}

# 2. Global KMS Keys
module "kms" {
  source      = "../../modules/kms"
  environment = "global"
}

# 3. Global EKS Cluster & Node IAM Roles
module "iam" {
  source      = "../../modules/iam"
  environment = "global"
}
