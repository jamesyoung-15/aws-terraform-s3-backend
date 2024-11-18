#!/usr/bin/env bash

# Validate the stack
aws cloudformation validate-template --template-body file://terraform-state-s3-backend.yml --region=us-east-1 --profile=Deployments