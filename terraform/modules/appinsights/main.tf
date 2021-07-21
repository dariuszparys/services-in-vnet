resource "azurerm_application_insights" "shared" {
  name                = var.app_insights_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  application_type    = "web"
  retention_in_days   = 90

  tags = {
    environment = var.env_code
  }
}
