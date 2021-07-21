output "virtual_network_id" {
  description = "Id of the container registry"
  value       = azurerm_virtual_network.shared.id
}

output "vnet_name" {
  description = "Name of the VNet"
  value       = azurerm_virtual_network.shared.name
}

output "private_endpoints_subnet_id" {
  description = "Private Endpoints Subnet Id"
  value       = azurerm_subnet.private_endpoints.id
}

output "private_endpoints_subnet_name" {
  description = "Private Endpoints Subnet Name"
  value       = azurerm_subnet.private_endpoints.name
}

output "services_subnet_id" {
  description = "Services Subnet Id"
  value       = azurerm_subnet.services.id
}

output "services_subnet_name" {
  description = "Services Subnet Name"
  value       = azurerm_subnet.services.name
}

output "gateway_subnet_id" {
  description = "Gateway Subnet Id"
  value       = azurerm_subnet.gateway.id
}

output "gateway_subnet_name" {
  description = "Gateway Subnet Name"
  value       = azurerm_subnet.gateway.name
}
