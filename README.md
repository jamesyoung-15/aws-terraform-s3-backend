# Cloudformation Terraform Remote Backend w/ S3 + DynamoDB

My CloudFormation for Terraform backend using S3 and DynamoDB for storing remote states.

## AWS CLI Usage

Make sure to set the correct profile eg.`--profile my_account`

Validate Cloudformation stack:

``` bash
aws cloudformation validate-template --template-body file://terraform-state-s3-backend.yml --region us-east-1 --profile my_account
```

Create stack:

``` bash
aws cloudformation create-stack --region us-east-1 --stack-name Terraform-State-Backend-Resources --enable-termination-protection --template-body file://terraform-state-s3-backend.yml --profile my_account
```

Change bucket and table name by passing parameter values eg:

``` bash
--parameters ParameterKey=TerraformStateBucketName,ParameterValue=terraform-state-backend-jyylab ParameterKey=TerraformStateLockTableName,ParameterValue=terraform-state-locks
```

So passing parameter will look like:

``` bash
aws cloudformation create-stack --region us-east-1 --stack-name Terraform-State-Backend-Resources --enable-termination-protection --template-body file://terraform-state-s3-backend.yml --parameters ParameterKey=TerraformStateBucketName,ParameterValue=terraform-state-backend-jyylab ParameterKey=TerraformStateLockTableName,ParameterValue=terraform-state-locks --profile my_account
```

Delete stack:

``` bash
aws cloudformation delete-stack --stack-name Terraform-State-Backend-Resources --profile my_account
```