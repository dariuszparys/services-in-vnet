resource "azurerm_application_insights" "this" {
  name                = local.app_insights_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  application_type    = "web"
  retention_in_days   = 90  
}
