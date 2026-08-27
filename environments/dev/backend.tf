terraform {

  backend "s3" {

    bucket         = "echolife-terraform-state"

    key            = "dev/terraform.tfstate"

    region         = "ap-south-1"

    dynamodb_table = "terraform-lock"

    encrypt = true
  }
}
