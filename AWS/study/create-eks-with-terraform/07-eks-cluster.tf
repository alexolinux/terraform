locals {
  kube_version = var.kube_version
  eks_name     = "eks-ckad"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster.html

data "aws_iam_policy" "amazon_eks_cluster_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

#https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role" "eks_cluster_role" {
  name = "AWSClusterRoleEKS"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowEKSRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags_all,
    {
      "Name"    = "AWSClusterRoleEKS"
      "Service" = "eks"
    }
  )
}

resource "aws_iam_role_policy_attachment" "attach_eks_cluster_policy" {
  policy_arn = data.aws_iam_policy.amazon_eks_cluster_policy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

#https://github.com/tensult/terraform/blob/master/aws/Kubernetes/cluster/eks-cluster.tf
resource "aws_eks_cluster" "eks_cluster" {
  name     = local.eks_name
  version  = local.kube_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_us_east_1[0].id,
      aws_subnet.private_us_east_1[1].id,
      aws_subnet.public_us_east_1[0].id,
      aws_subnet.public_us_east_1[1].id,
    ]

    endpoint_private_access = false
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.attach_eks_cluster_policy
  ]

  tags = merge(
    var.tags_all,
    {
      "Name" = "${local.eks_name}"
    }
  )
}

output "eks_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}