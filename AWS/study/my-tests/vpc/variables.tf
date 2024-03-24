#-- VPC Vars

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  default = []
}

variable "public_subnet_count" {
  default = 2
}

variable "private_subnet_count" {
  default = 2
}

variable "database_subnet_count" {
  default = 2
}

variable "name" {
  type    = string
  default = ""
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "enable_dns_support" {
  type    = bool
  default = "true"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = "true"
}

variable "enable_nat_gateway" {
  description = "Set to true to enable the creation of a NAT gateway, or false to disable it."
  type        = bool
  default     = true
}

#-- Subnet Vars

variable "map_public_ip_on_launch" {
  type    = bool
  default = "true"
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