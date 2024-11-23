# set region
provider "aws" {
  region = "us-east-1"
}

# get root organization id
data "aws_organizations_organization" "caller_org" {}

# allow access to s3 bucket only from the organization
data "aws_iam_policy_document" "s3_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.s3_state_bucket.arn}"]
    condition {
      test     = "StringEquals"
      values   = ["${data.aws_organizations_organization.caller_org.id}"]
      variable = "aws:PrincipalOrgID"
    }
  }
}

# allow access to dynamodb table only from the organization
data "aws_iam_policy_document" "dynamodb_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    effect    = "Allow"
    actions   = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = ["${aws_dynamodb_table.lock_table.arn}"]
    condition {
      test     = "StringEquals"
      values   = ["${data.aws_organizations_organization.caller_org.id}"]
      variable = "aws:PrincipalOrgID"
    }
  }
}

# create s3 bucket for terraform state
resource "aws_s3_bucket" "s3_state_bucket" {
  bucket = var.bucket_name

  tags = {
    "terraform_state_backend" = "s3_states"
    "terraform_managed"       = "true"
  }
}

# block public access to the s3 bucket
resource "aws_s3_bucket_public_access_block" "s3_block_public_access" {
  bucket = aws_s3_bucket.s3_state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# server side encryption for the s3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.s3_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# enable versioning for the s3 bucket
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.s3_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# attach policy to s3 bucket
resource "aws_s3_bucket_policy" "s3_allow_access_from_org" {
  bucket = aws_s3_bucket.s3_state_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json

  depends_on = [aws_s3_bucket_public_access_block.s3_block_public_access]
}



# create dynamodb table for terraform state lock
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

# attach policy to dynamodb table
resource "aws_dynamodb_resource_policy" "lock_table_policy" {
  resource_arn = aws_dynamodb_table.lock_table.arn
  policy       = data.aws_iam_policy_document.dynamodb_policy.json
}