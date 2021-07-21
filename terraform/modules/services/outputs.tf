output "app_service_plan_id" {
  description = "Id of the elastic service plan"
  value       = azurerm_app_service_plan.services.id
}

output "functionapp_id" {
  description = "Id of the function app"
  value       = azurerm_function_app.services.id
}

output "functionapp_url" {
  description = "Url of the function app"
  value       = azurerm_function_app.services.default_hostname
}

output "appservice_id" {
  description = "Id of the app service"
  value       = azurerm_app_service.services.id
}

output "appservice_url" {
  description = "Url of the app service"
  value       = azurerm_app_service.services.default_site_hostname
}
