variable "tags_all" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default = {
    Name        = "EKS-CKAD"
    Environment = "Development"
    managedby   = "terraform"
    author      = "alexolinux"
  }
}

variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "The AWS region"
}

variable "azs" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "List of Availability Zones"
}

variable "vpc_name" {
  default     = "eks-ckad-vpc"
  type        = string
  description = "The name of the Main VPC for the EKS Cluster"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19"]
  description = "Value of the private subnet CIDR blocks"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.64.0/19", "10.0.96.0/19"]
  description = "Value of the public subnet CIDR blocks"
}

variable "eks_name" {
  default     = "eks-ckad"
  type        = string
  description = "The name of the EKS Cluster"
}

variable "eks_names" {
  type        = list(string)
  default     = ["eks-ckad"]
  description = "List of EKS Cluster names"
}

#https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
variable "kube_version" {
  default     = "1.32"
  type        = string
  description = "The Kubernetes Version"
}

#aws eks describe-addon-versions --addon-name metrics-server --kubernetes-version 1.32 --region <aws_region>
variable "addon_version_metrics_server" {
  default     = "v0.7.2-eksbuild.4"
  type        = string
  description = "The version of the Metrics Server Addon"
}

#aws eks describe-addon-versions --addon-name vpc-cni --kubernetes-version 1.32 --region <aws_region>
variable "addon_version_vpc_cni" {
  default     = "v1.19.6-eksbuild.1"
  type        = string
  description = "The version of the VPC CNI Addon"
}

variable "addon_version_coredns" {
  default     = "v1.11.4-eksbuild.14"
  type        = string
  description = "The version of the CoreDNS Addon"
}

variable "addon_version_kube_proxy" {
  default     = "v1.32.5-eksbuild.2"
  type        = string
  description = "The version of the kube-proxy Addon"
}

variable "addon_version_ebs_csi_driver" {
  default     = "v1.44.0-eksbuild.1"
  type        = string
  description = "The version of the EBS CSI Addon"
}

variable "force_update_version" {
  default     = false
  type        = bool
  description = "Force update the Kubernetes version"
}

#https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType
variable "ami_type" {
  default     = "AL2_x86_64"
  type        = string
  description = "AMI type in the node group configuration"
}

variable "capacity_type" {
  default     = "ON_DEMAND"
  type        = string
  description = "The capacity type of your managed node group: ON_DEMAND | SPOT | CAPACITY_BLOCK"
}

variable "instance_types" {
  default     = ["t3.medium", "t3.large"]
  type        = list(string)
  description = "List of instance types associated with the EKS Node Group"
}

variable "disk_size" {
  default     = 30
  type        = number
  description = "Disk size in the node group configuration"
}
