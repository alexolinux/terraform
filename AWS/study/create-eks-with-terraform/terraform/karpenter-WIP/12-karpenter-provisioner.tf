resource "kubernetes_manifest" "provisioner" {
  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = "default"
    }
    spec = {
      requirements = [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["spot"] # Or "on-demand"
        },
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = ["amd64"]
        },
        {
          key      = "topology.kubernetes.io/zone"
          operator = "In"
          values   = var.azs
        },
        {
          key      = "karpenter.k8s.aws/instance-type"
          operator = "In"
          values   = var.instance_types # ["t3.medium", "t3.large"]
        }
      ]
      provider = {
        instanceTypes = var.instance_types # ["t3.medium", "t3a.medium"]
        amiFamily     = var.ami_type       # "AL2_x86_64"

        # Label your subnets/SG for Karpenter discovery
        subnetSelector = {
          "karpenter.sh/discovery" = "${var.eks_name}"
        }
        securityGroupSelector = {
          "karpenter.sh/discovery" = "${var.eks_name}"
        }

        limits = {
          cpu    = "200m"
          memory = "400m"
        }
      }
    }
  }

  depends_on = [helm_release.karpenter]

}

# karpenter.sh/discovery labels have been done to the private subnets and security groups: 03-subnets.tf and 09-nlb-security-group.tf
