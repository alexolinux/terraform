locals {
  project         = "testing"
  vpc_name        = "vpc-test"
  cluster_name    = "test-eks-cluster"
  cluster_version = "1.29"

}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_subnet" "private" {
  filter {
    name   = "tag:Name"
    values = ["private-subnet-1", "private-subnet-2"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8.4"

  cluster_name                   = local.cluster_name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  vpc_id     = data.aws_vpc.selected.id
  subnet_ids = data.aws_subnet.private.id

  tags = merge(
    var.tags,
    {
      Name    = local.cluster_name,
      Project = local.project
    }
  )

  eks_managed_node_groups = {
    dev = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = var.instance_types
    }
  }
}
