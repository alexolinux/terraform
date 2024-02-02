locals {
  project             = "study"
  resource_group_name = "rg-azure"
}

# Existing Resource Group
data "azurerm_resource_group" "selected" {
  name = local.resource_group_name
}

# Resource: Storage account
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "this" {
  name                            = "${var.environment}${var.storage_account_name}"
  resource_group_name             = data.azurerm_resource_group.selected.name
  location                        = data.azurerm_resource_group.selected.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  public_network_access_enabled   = var.public_network_access_enabled
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled

  tags = merge(
    var.global_tags,
    {
      name = "${var.environment}${var.storage_account_name}"
    },
  )
}

# Resource: Data Storage "Container"
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container
/* resource "azurerm_storage_container" "this" {
  name                  = "${var.environment}-${var.storage_container_name}-${local.project}"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = var.container_access_type
}
resource "azurerm_storage_account_network_rules" "this" {
  storage_account_id = azurerm_storage_account.this.id

  default_action             = "Allow"
  ip_rules                   = ["${local.ip_address}"]
  virtual_network_subnet_ids = [azurerm_subnet.example.id]
  bypass                     = ["Metrics"]
} */

#-- Azure Virtual Network Resources --------------------------------------------------------------------

# Resource: Network Security Group (NSG)
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "this" {
  name                = "${var.environment}-${var.security_group_name}-${local.project}"
  resource_group_name = data.azurerm_resource_group.selected.name
  location            = data.azurerm_resource_group.selected.location
}

# Resource: Network Security Group "Rule(s)"
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule
resource "azurerm_network_security_rule" "this" {
  name                   = var.internal_security_rule_name
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "*"
  #source_address_prefix       = "*"
  source_address_prefixes     = var.address_prefixes
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.selected.name
  network_security_group_name = azurerm_network_security_group.this.name
}

# Resource: Virtual Network
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "this" {
  name                = "${var.environment}-${var.virtual_network_name}-${local.project}"
  location            = data.azurerm_resource_group.selected.location
  resource_group_name = data.azurerm_resource_group.selected.name
  address_space       = var.address_space
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "default-subnet"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.this.id
  }

  tags = merge(
    var.global_tags,
    {
      name = "${var.environment}-${var.virtual_network_name}-${local.project}"
    },
  )
}

# Additional Resources: Subnet, NSG (NSG association) for VM access by DevOps Sysadmin.
resource "azurerm_network_security_group" "nsg_vm" {
  name                = "nsg-vm"
  location            = data.azurerm_resource_group.selected.location
  resource_group_name = data.azurerm_resource_group.selected.name

  security_rule {
    name                       = "allow_vms"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.address_prefix
    destination_address_prefix = "*"
  }
}

# Resource: Additional network subnet:
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "vm_subnet" {
  name                 = var.vm_subnet
  resource_group_name  = data.azurerm_resource_group.selected.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Associates a Network Security Group with a Subnet within a Virtual Network:
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "nsg_vm_asc" {
  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_vm.id
}

# Resource: VNetwork Interface & Azure Virtual Machine

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "vm_win" {
  name                          = "${var.environment}-${var.network_interface_name}-${local.project}-win"
  location                      = data.azurerm_resource_group.selected.location
  resource_group_name           = data.azurerm_resource_group.selected.name
  enable_accelerated_networking = var.enable_accelerated_networking
  ip_configuration {
    name                          = "${var.network_interface_name}_vm_win"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = var.private_ip_address_allocation
  }

  tags = merge(
    var.global_tags,
    {
      name = "${var.environment}-${var.network_interface_name}-${local.project}-win"
    },
  )
}

resource "azurerm_network_interface" "vm_linux" {
  name                          = "${var.environment}-${var.network_interface_name}-${local.project}-linux"
  location                      = data.azurerm_resource_group.selected.location
  resource_group_name           = data.azurerm_resource_group.selected.name
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.network_interface_name}-linux"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine

# VM_WIN
resource "azurerm_windows_virtual_machine" "vm_win" {
  name                = "${var.environment}-${var.vm_name_windows}"
  location            = data.azurerm_resource_group.selected.location
  resource_group_name = data.azurerm_resource_group.selected.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.vm_win.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = merge(
    var.global_tags,
    {
      name = "${var.environment}-${var.vm_name_windows}-${local.project}"
    },
  )
}

# VM_LINUX
resource "azurerm_linux_virtual_machine" "vm_linux" {
  name                = "${var.environment}-${var.vm_name_linux}"
  location            = data.azurerm_resource_group.selected.location
  resource_group_name = data.azurerm_resource_group.selected.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.vm_linux.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("./files/azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  tags = merge(
    var.global_tags,
    {
      name = "${var.environment}-${var.vm_name_linux}"
    },
  )
}
