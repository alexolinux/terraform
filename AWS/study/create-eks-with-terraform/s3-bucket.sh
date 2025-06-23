#!/bin/bash

if [ -z "${AWS_PROFILE}" ]; then
    echo "Required AWS_PROFILE environment is not set."
    exit 1
fi

get_region() {
    read -p "Enter the AWS Region (e.g., us-east-1): " aws_region
    aws_region="${aws_region:-us-east-1}"
}

get_bucket() {
    while true; do
        echo "Please provide a unique S3 bucket name. Example: my-random-tf-bucket-321"
        read -p "Enter the S3 Bucket Name: " bucket_name

        if [[ -n "$bucket_name" ]]; then
            echo "Bucket name accepted: $bucket_name"
            break  # Exit the loop if the input is valid
        else
            echo "Bucket name cannot be empty. Please try again."
        fi
    done
}

# Check the number of arguments passed to the script
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [create|destroy]"
    exit 1
fi

create_bucket() {
    aws s3api create-bucket \
        --bucket "${bucket_name}" \
        --region "${aws_region}"
}

destroy_bucket() {
    # Empty the bucket
    aws s3 rm s3://"${bucket_name}" --recursive

    # Delete the bucket
    aws s3api delete-bucket \
        --bucket "${bucket_name}"
    
    if [ $? -eq 0 ]; then
        echo "Bucket ${bucket_name} deleted successfully."
    else
        echo "Failed to delete bucket ${bucket_name}."
        exit 1
    fi
}

# Handle the command based on the argument
case "$1" in
    "create")
        get_bucket
        get_region
        create_bucket
        ;;
    "destroy")
        get_bucket
        destroy_bucket
        ;;
    *)
        echo "Invalid argument. Usage: $0 [create|destroy]"
        exit 1
        ;;
esac
