terraform {
  backend "s3" {
    bucket = "terraform-state-backend-jyylab" # Change to bucket name
    key    = "testing/test-backend"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock-jyylab" # Change to DynamoDB table name, might need to use ARN
    encrypt = true
  }
}