output "terraform_state_bucket" {
  description = "Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_lock_table" {
  description = "Terraform lock table"
  value       = aws_dynamodb_table.terraform_lock.name
}
