terraform {
  backend "s3" {
    bucket = "ax-aws-create-eks-with-terraform-2024"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
