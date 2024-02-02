# Resource Group
output "resource_group_id" {
  value = data.azurerm_resource_group.selected.id
}

output "resource_group_location" {
  value = data.azurerm_resource_group.selected.location
}

# Storage Account
output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

# Azure Virtual Network
output "virtual_network_id" {
  value = azurerm_virtual_network.this.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.this.name
}

# Network Security Group
output "network_security_group_id" {
  value = azurerm_network_security_group.this.id
}

output "network_security_group_name" {
  value = azurerm_network_security_group.this.name
}

# VM Subnet
output "azurerm_subnet_name" {
  value = azurerm_subnet.vm_subnet.name
}

output "azurerm_subnet_id" {
  value = azurerm_subnet.vm_subnet.id
}

# VNetwork Interfaces / Azure VMs

# Windows
output "azurerm_network_interface_win_id" {
  value = azurerm_network_interface.vm_win.id
}

output "azurerm_network_interface_win_name" {
  value = azurerm_network_interface.vm_win.name
}

output "azurerm_windows_virtual_machine_id" {
  value = azurerm_windows_virtual_machine.vm_win.id
}

output "azurerm_windows_virtual_machine_name" {
  value = azurerm_windows_virtual_machine.vm_win.name
}

output "azurerm_windows_virtual_machine_size" {
  value = azurerm_windows_virtual_machine.vm_win.size
}

output "azurerm_windows_virtual_machine_os_disk" {
  value = azurerm_windows_virtual_machine.vm_win.os_disk
}

# Linux
output "azurerm_network_interface_linux_id" {
  value = azurerm_network_interface.vm_linux.id
}

output "azurerm_network_interface_linux_name" {
  value = azurerm_network_interface.vm_linux.name
}


output "azurerm_linux_virtual_machine_id" {
  value = azurerm_linux_virtual_machine.vm_linux.id
}

output "azurerm_linux_virtual_machine_name" {
  value = azurerm_linux_virtual_machine.vm_linux.name
}

output "azurerm_linux_virtual_machine_size" {
  value = azurerm_linux_virtual_machine.vm_linux.size
}

output "azurerm_linux_virtual_machine_os_disk" {
  value = azurerm_linux_virtual_machine.vm_linux.os_disk
}
