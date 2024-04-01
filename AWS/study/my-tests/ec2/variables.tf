#-- ec2 Vars
variable "public_key" {
  description = "SSH Public String Key Pair"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1CjAysvZdq5Ch/as4s8R/wvXvWMwpP1V5VPMSkO5KH"
}

variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}

#Extra Vars: group_name/user_name/private_key
#might be defined using .tfvars or by using overrride.tf
#overrride.tf is included in .gitignore for sensitive data
variable "group_name" {
  description = "Linux Group"
  type        = string
}

variable "user_name" {
  description = "Linux User"
  type        = string
}

variable "private_key" {
  description = "Path to the private SSH key file"
  type        = string
  sensitive   = true
}

#-- Tag Vars
variable "tags" {
  type = map(string)
  default = {
    environment = "test"
    managed     = "terraform"
    createdby   = "devops"
  }
}
