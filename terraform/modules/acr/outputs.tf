output "container_registry_login_server" {
  description = "Container Registry Name"
  value       = azurerm_container_registry.shared.login_server
}

output "container_registry_username" {
  description = "Username of container registry"
  value       = azurerm_container_registry.shared.admin_username
}

output "container_registry_password" {
  description = "Password of container registry"
  value       = azurerm_container_registry.shared.admin_password
}