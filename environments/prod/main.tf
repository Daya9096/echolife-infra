# environments/prod/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # The region mandated by the architecture document
}

# The block you just shared:
module "vpc" {
  source = "../../modules/vpc"

  environment = "prod"
  vpc_cidr    = "10.2.0.0/16"
  azs         = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  
  public_subnets       = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  private_app_subnets  = ["10.2.32.0/19", "10.2.64.0/19", "10.2.96.0/19"]
  private_data_subnets = ["10.2.128.0/22", "10.2.132.0/22", "10.2.136.0/22"]
}
