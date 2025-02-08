provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84.0"
    }
    #Helm Provider (https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)
    helm = {
      source = "hashicorp/helm"
      version = "3.0.0-pre1"
    }
  }
}
