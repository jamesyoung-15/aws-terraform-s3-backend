variable "bucket_name" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
  default     = "terraform-state-backend-jyylab"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table to store Terraform state lock"
  type        = string
  default     = "terraform-state-lock-jyylab"
}