#!/bin/bash

# Replace these variables with your own values
BUCKET_NAME="${AWS_BUCKET_NAME}"
REGION="${AWS_REGION}"

# Validate that BUCKET_NAME and REGION are set
if [ -z "${AWS_BUCKET_NAME}" ]; then
  echo "Error: BUCKET_NAME is not set. Please set the AWS_BUCKET_NAME environment variable."
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  echo "Error: REGION is not set. Please set the AWS_REGION environment variable."
  exit 1
fi

# Check if AWS_PROFILE environment variable is set
if [ -z "${AWS_PROFILE}" ]; then
    echo "Required AWS_PROFILE environment is not set."
    exit 1
fi

# Check the number of arguments passed to the script
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [create|destroy]"
    exit 1
fi

# Function to create S3 bucket
create_bucket() {
    aws s3api create-bucket \
        --bucket "${BUCKET_NAME}" \
        --region "${REGION}"
}

# Function to destroy S3 bucket
destroy_bucket() {
    # Empty the bucket
    aws s3 rm s3://"${BUCKET_NAME}" --recursive

    # Delete the bucket
    aws s3api delete-bucket \
        --bucket "${BUCKET_NAME}"
}

# Handle the command based on the argument
case "$1" in
    "create")
        create_bucket
        ;;
    "destroy")
        destroy_bucket
        ;;
    *)
        echo "Invalid argument. Usage: $0 [create|destroy]"
        exit 1
        ;;
esac
