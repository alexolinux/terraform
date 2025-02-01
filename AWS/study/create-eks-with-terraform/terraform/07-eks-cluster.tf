locals {
  kube_version = var.kube_version
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster.html

#https://docs.aws.amazon.com/aws-managed-policy/latest/reference/policy-list.html
data "aws_iam_policy" "amazon_eks_cluster_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "amazon_eks_lb_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
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

resource "aws_iam_role_policy_attachment" "attach_eks_lb_policy" {
  policy_arn = data.aws_iam_policy.amazon_eks_lb_policy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

#https://github.com/tensult/terraform/blob/master/aws/Kubernetes/cluster/eks-cluster.tf
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_name
  version  = local.kube_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    #https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html
    endpoint_private_access = false
    endpoint_public_access  = true

    #https://docs.aws.amazon.com/eks/latest/best-practices/subnets.html
    subnet_ids = [
      aws_subnet.private_us_east_1[0].id,
      aws_subnet.private_us_east_1[1].id,
      aws_subnet.public_us_east_1[0].id,
      aws_subnet.public_us_east_1[1].id,
    ]
  }

  #https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
  bootstrap_self_managed_addons = false

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.attach_eks_cluster_policy,
    aws_iam_role_policy_attachment.attach_eks_lb_policy
  ]

  tags = merge(
    var.tags_all,
    {
      "Name" = "${var.eks_name}"
    }
  )
}

# AddOns for EKS Cluster

resource "aws_eks_addon" "metrics_server" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "metrics-server"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "kube-proxy"
}

# Optional: AddOn for EBS CSI Driver
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = "aws-ebs-csi-driver"
}

output "eks_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}
