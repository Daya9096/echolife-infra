# environments/stage/main.tf

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

module "vpc" {
  source = "../../modules/vpc"

  environment = "stage"
  vpc_cidr    = "10.1.0.0/16"
  azs         = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  
  public_subnets       = ["10.1.0.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  private_app_subnets  = ["10.1.32.0/19", "10.1.64.0/19", "10.1.96.0/19"]
  private_data_subnets = ["10.1.128.0/22", "10.1.132.0/22", "10.1.136.0/22"]
}
