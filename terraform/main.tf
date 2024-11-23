provider "aws" {
  region  = "us-east-1"
  profile = "Deployments"
}

data "aws_organizations_organization" "caller_org" {}


data "aws_iam_policy_document" "s3_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = [aws_s3_bucket.s3_state_bucket.arn]
    condition {
      test     = "StringEquals"
      values   = ["${data.aws_organizations_organization.caller_org.id}"]
      variable = "aws:PrincipalOrgID"
    }
  }
}

data "aws_iam_policy_document" "dynamodb_policy" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = []
    condition {
      test     = "StringEquals"
      values   = ["${data.aws_organizations_organization.caller_org.id}"]
      variable = "aws:PrincipalOrgID"
    }
  }
}

resource "aws_s3_bucket" "s3_state_bucket" {
  bucket = var.bucket_name

  tags = {
    "terraform_state_backend" = "s3_states"
    "terraform_managed"       = "true"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_block_public_access" {
  bucket = aws_s3_bucket.s3_state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "s3_allow_access_from_org" {
  bucket = aws_s3_bucket.s3_state_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json

  depends_on = [ aws_s3_bucket_public_access_block.s3_block_public_access ]
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.s3_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}



resource "aws_dynamodb_table" "lock_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    "terraform_state_backend" = "dynamodb_locks"
    "terraform_managed"       = "true"
  }
}

resource "aws_dynamodb_resource_policy" "lock_table_policy" {
  resource_arn = aws_dynamodb_table.lock_table.arn
  policy = data.aws_iam_policy_document.dynamodb_policy.json
}