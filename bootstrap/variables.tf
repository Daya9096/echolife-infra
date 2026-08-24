variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "terraform_state_bucket" {
  description = "Terraform state S3 bucket name"
  type        = string
}

variable "terraform_lock_table" {
  description = "Terraform lock DynamoDB table"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
