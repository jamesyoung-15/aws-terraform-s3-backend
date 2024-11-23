terraform {
  backend "s3" {
    bucket = "terraform-state-backend-jyylab" # Change to bucket name
    key    = "testing/test-backend"
    region = "us-east-1"
    dynamodb_table = "terraform-state-locks" # Change to DynamoDB table name
    encrypt = true
    shared_config_files = [ "~/.aws/credentials" ] # point to AWS credentials file
    profile = "Deployments" # set profile name where backend bucket is located
  }
}

resource "random_string" "bucket_suffix" {
  length = 7
  special = false
  upper = false
}

resource "aws_s3_bucket" "test-bucket" {
  depends_on = [ random_string.bucket_suffix ]
  bucket = "terraform-test-bucket-jyylab-${random_string.bucket_suffix.result}"
}