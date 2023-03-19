# Private variables
variable "environment" {
  type        = string
  description = "Project Environment"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure Region Location"
  default     = "us-south-central"
}

variable "subscription_id" {
  type        = string
  description = "Azure Account Subscription ID"
  default     = ""
}

variable "client_id" {
  type        = string
  description = "Azure Client ID"
  default     = ""
}

variable "client_secret" {
  type        = string
  description = "Azure Client Secret"
  default     = ""
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
  default     = ""
}

#-- ---------------------------
# Variables: resource group
#-- ---------------------------
variable "resource_group_id" {
  type        = string
  description = "Azure resource group ID"
  default     = ""
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name"
  default     = ""
}

#-- ---------------------------
# Variables: storage account
#-- ---------------------------
variable "storage_account_name" {
  type        = string
  description = "Storage account name"
  default     = "staccount"
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
variable "account_tier" {
  type        = string
  description = "Manages an Azure Storage Account"
  default     = "Standard"
}

#https://learn.microsoft.com/en-us/azure/storage/common/storage-redundancy
variable "account_replication_type" {
  type        = string
  description = "Storage account replication types: LRS|ZRS|GRS|GZRS"
  default     = "LRS"
}

variable "shared_access_key_enabled" {
  type        = bool
  description = "Permits requests to be authorized with the account access key via Shared Key."
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Defines wether the public network access is enabled"
  default     = false
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  description = "Allows anonymous access to blobs within the storage account"
  default     = true
}

# azurerm_storage_container
variable "storage_container_name" {
  type        = string
  description = "The name of the Container"
  default     = "guru"
}

variable "container_access_type" {
  type        = string
  description = "Access Level configured for this Container"
  default     = "private"
}

#-- ---------------------------
# Variables: Network
#-- ---------------------------
variable "security_group_name" {
  type        = string
  description = "Specifies the name of the network security group"
  default     = "nsg_default"
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network"
  default     = "aznet"
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
  default     = ["10.0.0.0/16"]
}

variable "address_prefix" {
  type        = string
  description = "Allowed access Ip address."
  #default     = 
}

variable "address_prefixes" {
  type        = list(string)
  description = "Allowed access list."
  default     = ["10.0.0.0/16"]
}

variable "internal_security_rule_name" {
  type        = string
  description = "value"
  default     = "allow_internal"
}

variable "vm_subnet" {
  type        = string
  description = "Azure virtual network subnet (additional)"
  default     = "vm_subnet"
}

#-- -------------------------------
# Variables: NIC & virtual machine
#-- -------------------------------
variable "network_interface_name" {
  type        = string
  description = "Network Interface name"
  default     = "vnic"
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS Servers."
  default     = null
}

#https://docs.microsoft.com/azure/virtual-network/create-vm-accelerated-networking-cli
variable "enable_accelerated_networking" {
  type        = bool
  description = "Enables Accelerated Networking"
  default     = true
}

variable "private_ip_address_allocation" {
  type        = string
  description = "Method used for the Private IP Address - Values: Dynamic | Static"
  default     = "Dynamic"
}

variable "private_ip_address" {
  type        = string
  description = "The Static IP Address which should be used (whether ip allocation is Static)"
  default     = ""
}

variable "public_ip_address_id" {
  type        = string
  description = "Reference to a Public IP Address to associate with this NIC"
  default     = ""
}

variable "vm_name_windows" {
  type        = string
  description = "Virtual Machine name"
  default     = "vm_win"
}

variable "vm_name_linux" {
  type        = string
  description = "Virtual Machine name"
  default     = "vm_linux"
}

#https://azure.microsoft.com/en-us/pricing/details/virtual-machines/series/
#https://learn.microsoft.com/pt-br/azure/virtual-machines/sizes
variable "vm_size" {
  type        = string
  description = "The VM type which should be used for the Virtual Machine"
  default     = "Standard_F2"
}

variable "admin_username" {
  type        = string
  description = "Admin Username"
  default     = "devops"
}

variable "admin_password" {
  type        = string
  description = "Admin Password"
  default     = ""
}

#-- Tags -------------------------------------------------------------------------------------
variable "global_tags" {
  type        = map(any)
  description = "(Optional) A map of tags to be applied globally on all Azure resource groups"
  default = {
    platform  = "infrastructure"
    boundary  = "devops"
    project   = "Study"
    provider  = "azure"
    createdby = "terraform"
    team      = "devops"
  }
}
