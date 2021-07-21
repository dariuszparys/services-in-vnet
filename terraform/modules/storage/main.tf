resource "azurerm_storage_account" "shared" {
  name                      = var.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  
  account_tier              = "Standard"
  account_replication_type  = "LRS"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.env_code
  }
}