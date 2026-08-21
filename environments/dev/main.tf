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
# Dev Environment Resources (Existing)
# ====================================================================
module "waf" {
  source = "../../modules/waf"

  environment = "dev"
  alb_arn     = "arn:aws:elasticloadbalancing:ap-south-1:123456789012:loadbalancer/app/echolife-dev-alb/dummy123"
}

module "s3" {
  source = "../../modules/s3"

  environment = "dev"
  bucket_name = "echolife-media-dev-8374929"
}

resource "aws_security_group" "dev_rds" {
  name        = "echolife-dev-rds-sg"
  description = "Security group for Dev RDS instances"
  vpc_id      = data.aws_vpc.shared.id

  # Ingress from the shared EKS subnets
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.32.0/19", "10.0.64.0/19", "10.0.96.0/19"]
  }
}

# ====================================================================
# NEW: Dev Secrets, RDS, and Compute
# ====================================================================
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "echolife/dev/rds/credentials"
  description = "PostgreSQL credentials for Dev"
  tags        = { Environment = "dev" }
}

resource "aws_secretsmanager_secret_version" "rds_credentials_val" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({ username = "dev_admin", password = "change_me_in_console" })
}

# Dev Database (Small, Single AZ)
module "rds" {
  source                 = "../../modules/rds"
  environment            = "dev"
  instance_class         = "db.t4g.micro"   
  multi_az               = false            
  allocated_storage      = 20               
  secret_arn             = aws_secretsmanager_secret.rds_credentials.arn
  # We connect the security group you created above directly to the database here!
  vpc_security_group_ids = [aws_security_group.dev_rds.id] 
}

# Dev EKS Node Pool (Shared General Compute)
module "eks_nodes" {
  source         = "../../modules/eks" # Adjust path to match your actual eks module folder
  environment    = "dev"
  instance_types = ["t3.medium"]
  min_size       = 1
  max_size       = 3
}
