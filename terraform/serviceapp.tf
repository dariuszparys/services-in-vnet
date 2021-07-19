resource "azurerm_app_service_plan" "modelapiplan" {
  name                = local.app_service_plan_linux_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P2v2"
  }
}

resource "azurerm_app_service" "modelapisvc" {
  name                = local.modelapi_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  app_service_plan_id = azurerm_app_service_plan.modelapiplan.id

  site_config {
    app_command_line = ""
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = "${azurerm_application_insights.this.instrumentation_key}"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=${azurerm_application_insights.this.instrumentation_key}"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = "false"
    "DOCKER_REGISTRY_SERVER_PASSWORD"       = "${azurerm_container_registry.this.admin_password}"
    "DOCKER_REGISTRY_SERVER_URL"            = "https://${azurerm_container_registry.this.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"       = "${azurerm_container_registry.this.admin_username}"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "model_api_pe" {
  name                = "${local.resource_prefix}-model-api-pe-${local.seed_suffix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml.id

  private_service_connection {
    name                           = "${local.resource_prefix}-model-api-psc-${local.seed_suffix}"
    private_connection_resource_id = azurerm_app_service.modelapisvc.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-websites"
    private_dns_zone_ids = [azurerm_private_dns_zone.websites_zone.id]
  }

  depends_on = [
    azurerm_private_endpoint.core_api_pe
  ]
}
