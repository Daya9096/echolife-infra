provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = "EchoLife"
      ManagedBy   = "Terraform"
      Owner       = "Cloud-Team"
      Environment = "Bootstrap"
    }
  }
}
