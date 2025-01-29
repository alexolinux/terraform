terraform {
  backend "s3" {
    bucket = "axvs-aws-create-eks-with-terraform-9999"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
