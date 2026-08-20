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
  alb_arn     = "arn:aws:elasticloadbalancing:ap-south-1:123456789012:loadbalancer/app/echolife-prod-alb/dummy123"
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

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
  }
}

# ====================================================================
# Prod Secrets, RDS, and Compute
# ====================================================================
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "echolife/prod/rds/credentials"
  description = "PostgreSQL credentials for Prod"
  tags        = { Environment = "prod" }
}

resource "aws_secretsmanager_secret_version" "rds_credentials_val" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({ username = "prod_admin", password = "change_me_in_console" })
}

# Prod Database (High Availability Multi-AZ)
module "rds" {
  source                 = "../../modules/rds"
  environment            = "prod"
  instance_class         = "db.m7g.xlarge"   
  multi_az               = true            
  allocated_storage      = 500               
  secret_arn             = aws_secretsmanager_secret.rds_credentials.arn
  vpc_security_group_ids = [aws_security_group.prod_rds.id] 
}

# Prod EKS Node Pool (Strictly Isolated)
module "eks_nodes" {
  source         = "../../modules/eks" 
  environment    = "prod"
  instance_types = ["m5.xlarge"]
  min_size       = 3
  max_size       = 10
  
  kubernetes_taints = [{
    key    = "environment"
    value  = "prod"
    effect = "NO_SCHEDULE"
  }]
}
