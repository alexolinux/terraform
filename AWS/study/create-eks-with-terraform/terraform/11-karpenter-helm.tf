resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter/karpenter"
  chart      = "karpenter"
  namespace  = "karpenter"

  set {
    name  = "controller.clusterName"
    value = aws_eks_cluster.eks_cluster.name # Reference your EKS cluster name
  }

  set {
    name  = "controller.aws.region"
    value = var.aws_region
  }

  set {
    name  = "controller.iam.controllerRoleName"
    value = aws_iam_role.karpenter_controller.name
  }

  set {
    name  = "controller.iam.provisionerRoleName"
    value = aws_iam_role.karpenter_provisioner.name
  }

}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}
