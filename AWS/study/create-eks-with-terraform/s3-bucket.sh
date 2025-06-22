#!/bin/bash

# Check if AWS_PROFILE environment variable is set
if [ -z "${AWS_PROFILE}" ]; then
    echo "Required AWS_PROFILE environment is not set."
    exit 1
fi

# Prompt for AWS region
read -p "Enter the AWS Region (e.g., us-east-1): " aws_region
aws_region="${aws_region:-us-east-1}"

# Validate that bucket_name and aws_region are set
while true; do
  echo "Creating S3 bucket for Terraform backend state storage."
  echo "Example: cmd-rm-rf-ops-321"
  read -p "Enter the S3 Bucket Name: " bucket_name
  if [[ -n "$bucket_name" ]]; then
    echo "Bucket name accepted: $bucket_name"
    break
  else
    echo "Bucket name cannot be empty. Please try again."
  fi
done

# Check the number of arguments passed to the script
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [create|destroy]"
    exit 1
fi

# Function to create S3 bucket
create_bucket() {
    aws s3api create-bucket \
        --bucket "${bucket_name}" \
        --region "${aws_region}"
}

# Function to destroy S3 bucket
destroy_bucket() {
    # Empty the bucket
    aws s3 rm s3://"${bucket_name}" --recursive

    # Delete the bucket
    aws s3api delete-bucket \
        --bucket "${bucket_name}"
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

