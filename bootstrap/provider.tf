provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "EchoLife"
      ManagedBy   = "Terraform"
      Owner       = "Cloud-Team"
      Environment = "Bootstrap"
    }
  }
}
