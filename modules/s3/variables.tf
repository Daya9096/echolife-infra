variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}
