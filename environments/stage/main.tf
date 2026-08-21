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
# Stage Environment Resources
# ====================================================================
module "waf" {
  source = "../../modules/waf"

  environment = "stage"
  alb_arn     = "arn:aws:elasticloadbalancing:ap-south-1:123456789012:loadbalancer/app/echolife-stage-alb/dummy123"
}

module "s3" {
  source = "../../modules/s3"

  environment = "stage"
  bucket_name = "echolife-media-stage-8374929"
}

resource "aws_security_group" "stage_rds" {
  name        = "echolife-stage-rds-sg"
  description = "Security group for Stage RDS instances"
  vpc_id      = data.aws_vpc.shared.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
  }
}

# ====================================================================
# Stage Secrets, RDS, and Compute
# ====================================================================
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "echolife/stage/rds/credentials"
  description = "PostgreSQL credentials for Stage"
  tags        = { Environment = "stage" }
}

resource "aws_secretsmanager_secret_version" "rds_credentials_val" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({ username = "stage_admin", password = "change_me_in_console" })
}

# Stage Database (Production-like sizing)
module "rds" {
  source                 = "../../modules/rds"
  environment            = "stage"
  instance_class         = "db.m7g.large"   
  multi_az               = false            
  allocated_storage      = 100               
  secret_arn             = aws_secretsmanager_secret.rds_credentials.arn
  vpc_security_group_ids = [aws_security_group.stage_rds.id] 
}

# Stage EKS Node Pool
module "eks_nodes" {
  source         = "../../modules/eks" 
  environment    = "stage"
  instance_types = ["m5.large"]
  min_size       = 2
  max_size       = 5
}
