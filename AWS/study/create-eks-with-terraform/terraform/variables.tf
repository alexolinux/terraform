variable "tags_all" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default = {
    Name        = "CloudGuru"
    Environment = "Development"
    managedby   = "terraform"
    Tutorial    = "Anton Putra - EKS Cluster"
  }
}

variable "eks_name" {
  default     = "eks-ckad"
  type        = string
  description = "The name of the EKS Cluster"
}

#https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
variable "kube_version" {
  default     = "1.32"
  type        = string
  description = "The Kubernetes Version"
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
  description = "Valid Values: ON_DEMAND | SPOT"
}

variable "instance_types" {
  default     = ["t3.large"] #["t3.micro", "t3.medium", "t3.large"]
  type        = list(string)
  description = "List of instance types associated with the EKS Node Group"
}

variable "disk_size" {
  default     = 18
  type        = number
  description = "Disk size in the node group configuration"
}
