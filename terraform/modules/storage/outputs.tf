output "storage_account_id" {
  description = "Id of the storage account"
  value       = azurerm_storage_account.shared.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.shared.name
}

output "storage_account_access_key" {
  description = "Primary key of the storage account"
  value       = azurerm_storage_account.shared.primary_access_key
}