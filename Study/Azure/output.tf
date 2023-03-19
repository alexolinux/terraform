output "resource_group_id" {
  value = data.azurerm_resource_group.selected.id
}

output "resource_group_location" {
  value = data.azurerm_resource_group.selected.location
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "storage_container_id" {
  value = "azurerm_storage_container.this.id"
}

output "storage_container_name" {
  value = "azurerm_storage_container.this.name"
}

output "virtual_network_id" {
  value = azurerm_virtual_network.this.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.this.name
}