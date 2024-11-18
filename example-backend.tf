terraform {
  backend "s3" {
    bucket = "my-bucket" # Change to bucket name
    key    = "testing/test-backend"
    region = "us-east-1"
    dynamodb_table = "terraform-state-locks" # Change to DynamoDB table name
    encrypt = true
    shared_config_files = [ "~/.aws/credentials" ] # point to AWS credentials file
    profile = "my_account" # set profile name where backend bucket is located
  }
}