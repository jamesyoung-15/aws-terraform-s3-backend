#!/usr/bin/env bash

aws cloudformation create-stack --template-body file://terraform-state-s3-backend.yml --stack-name Terraform-State-Backend-Resources --region us-east-1 --profile Deployments