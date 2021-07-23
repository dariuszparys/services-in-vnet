output "resource_group_created" {
  description = "Name of the resource group created and used for provisioning"
  value       = azurerm_resource_group.this.name
}

output "test_call" {
  description = "Constructed none VNet endpoint"
  value       = "https://${module.services[0].functionapp_url}/api/goto?url=https://${module.services[0].appservice_url}"
}

output "function_app_endpoint" {
  description = "Id of the app service"
  value       = module.services[0].functionapp_url
}

output "app_service_endpoint" {
  description = "Url of the app service"
  value       = module.services[0].appservice_url
}
