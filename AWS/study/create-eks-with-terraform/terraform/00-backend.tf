terraform {
  backend "s3" {
    bucket = "ax-aws-create-eks-with-terraform-2099"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
