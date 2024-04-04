variable "tags_all" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {
    Name        = "CloudGuru"
    Environment = "Development"
    managedby   = "terraform"
    Tutorial    = "Anton Putra - EKS Cluster"
  }
}
