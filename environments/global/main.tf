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

# ====================================================================
# SHARED GLOBAL NETWORK (Supports Dev, Stage, and Prod EKS Namespaces)
# ====================================================================
module "vpc" {
  source               = "../../modules/vpc"
  environment          = "global"
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  public_subnets       = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_app_subnets  = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
  private_data_subnets = ["10.0.128.0/22", "10.0.132.0/22", "10.0.136.0/22"]
}

# ====================================================================
# GLOBAL KMS & IAM (Security Core)
# ====================================================================
module "kms" {
  source      = "../../modules/kms"
  environment = "global"
}

module "iam" {
  source      = "../../modules/iam"
  environment = "global"
}

# ====================================================================
# SHARED EKS CLUSTER
# ====================================================================
module "eks" {
  source = "../../modules/eks"

  project_name = "echolife"
  environment  = "global"
  aws_region   = "ap-south-1"

  cluster_name    = "echolife-eks"
  cluster_version = "1.33"

  # VPC Module Outputs mapped to EKS
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_app_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  # Node Group
  node_group_name = "default-node-group"
  instance_types  = ["c7i-flex.large"]

  desired_size = 2
  min_size     = 2
  max_size     = 4

  tags = {
    Project     = "echolife"
    Environment = "global"
    ManagedBy   = "Terraform"
  }
}
