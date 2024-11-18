terraform {
  backend "s3" {
    bucket = "terraform-state-backend-jyylab"
    key    = "testing/test-backend"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }
}