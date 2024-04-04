#!/bin/bash

# Replace these variables with your own values
BUCKET_NAME="ax-aws-create-eks-with-terraform-2024"
REGION="us-east-1"

# Check if AWS_PROFILE environment variable is set
if [ -z "${AWS_PROFILE}" ]; then
    echo "Required AWS_PROFILE environment is not set."
    exit 1
fi

# Create S3 bucket
aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${REGION}"

# Check if the bucket creation was successful
if [ "$?" -eq 0 ]; then
    echo "S3 bucket '${BUCKET_NAME}' created successfully."
else
    echo "Error creating S3 bucket '${BUCKET_NAME}'."
fi
