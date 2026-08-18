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
# Data Sources: Fetch the Shared Global Network
# ====================================================================
data "aws_vpc" "shared" {
  tags = {
    Environment = "global"
  }
}

# ====================================================================
# Prod Environment Resources
# ====================================================================
module "waf" {
  source = "../../modules/waf"

  environment = "prod"
  alb_arn     = "arn:aws:elasticloadbalancing:ap-south-1:123456789012:loadbalancer/app/echolife-prod-alb/dummy789"
}

module "s3" {
  source = "../../modules/s3"

  environment = "prod"
  bucket_name = "echolife-media-prod-8374929"
}

resource "aws_security_group" "prod_rds" {
  name        = "echolife-prod-rds-sg"
  description = "Security group for Prod RDS instances"
  vpc_id      = data.aws_vpc.shared.id

  # Ingress from the shared EKS subnets
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
  }
}
