provider "aws" {
  region = "us-east-1"
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