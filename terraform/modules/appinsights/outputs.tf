output "app_insights_id" {
  description = "Id of application insights"
  value       = azurerm_application_insights.shared.id
}

output "instrumentation_key" {
  description = "Instrumentation key of application insights"
  value       = azurerm_application_insights.shared.instrumentation_key
}