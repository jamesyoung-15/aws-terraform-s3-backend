output "dynamodb_table_name" {
  description = "DynamicDB table for locking."
  value = aws_dynamodb_table.lock_table
}

output "bucket_name" {
  description = "S3 bucket backend for state."
  value = aws_s3_bucket.s3_state_bucket
}