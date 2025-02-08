#https://karpenter.sh/docs/getting-started/migrating-from-cas/#create-iam-roles
resource "aws_iam_role" "karpenter_provisioner" {
  name = "KarpenterNodeRole-${var.eks_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_provisioner_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter_provisioner.name
}

resource "aws_iam_role_policy_attachment" "karpenter_provisioner_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter_provisioner.name
}

resource "aws_iam_role_policy_attachment" "karpenter_provisioner_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter_provisioner.name
}

resource "aws_iam_role_policy_attachment" "karpenter_provisioner_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.karpenter_provisioner.name
}

#IAM Role for Karpenter controller
resource "aws_iam_role" "karpenter_controller" {
  name = "karpenter-controller"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.karpenter_controller.name
}
