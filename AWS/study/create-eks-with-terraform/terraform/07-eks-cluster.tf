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

resource "aws_iam_role_policy_attachment" "attach_eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "attach_eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

#https://github.com/tensult/terraform/blob/master/aws/Kubernetes/cluster/eks-cluster.tf
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_name
  version  = local.kube_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    #https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html
    endpoint_private_access = true
    endpoint_public_access  = true
    #public_access_cidrs     = ["YOUR_OFFICE_IP/32"] # Replace with your trusted IP(s)

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
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = var.addon_version_metrics_server != "" ? var.addon_version_metrics_server : null
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = var.addon_version_vpc_cni != "" ? var.addon_version_vpc_cni : null
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = var.addon_version_coredns != "" ? var.addon_version_coredns : null
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = var.addon_version_kube_proxy != "" ? var.addon_version_kube_proxy : null
}

# Optional: AddOn for EBS CSI Driver
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = var.addon_version_ebs_csi_driver != "" ? var.addon_version_ebs_csi_driver : null
}

# OIDC Provider for EKS Cluster - required for IAM Roles for Service Accounts (IRSA)
resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
}

data "tls_certificate" "oidc_thumbprint" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# Outputs
output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_oidc_issuer_url" {
  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}
