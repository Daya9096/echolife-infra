terraform {
  backend "s3" {
    bucket         = "echolife-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "echolife-terraform-lock"
    encrypt        = true
  }
}
