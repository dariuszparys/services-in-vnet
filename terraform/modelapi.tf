resource "azurerm_app_service_plan" "modelapiplan" {
  name                = local.app_service_plan_linux_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "PremiumV2"
    # P2v2 = 420 total ACU, 7 GB memory, Dv2-Series compute equivalent
    size = "P2v2"
  }
}

resource "azurerm_app_service" "modelapisvc" {
  name                = local.modelapi_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
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
  count               = var.deploy_to_vnet ? 1 : 0
  name                = "${local.resource_prefix}-model-api-pe-${local.seed_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml[count.index].id

  private_service_connection {
    name                           = "${local.resource_prefix}-model-api-psc-${local.seed_suffix}"
    private_connection_resource_id = azurerm_app_service.modelapisvc.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

}

data "azurerm_private_endpoint_connection" "model_api_conn" {
  count                 = var.deploy_to_vnet ? 1 : 0  
  name                  = azurerm_private_endpoint.model_api_pe[count.index].name
  resource_group_name   = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_a_record" "model_api_dns_a_record" {
  count                 = var.deploy_to_vnet ? 1 : 0  

  name                  = lower(azurerm_app_service.modelapisvc.name)
  zone_name             = azurerm_private_dns_zone.websites_zone[count.index].name
  resource_group_name   = data.azurerm_resource_group.this.name
  ttl                   = 300
  records               = [data.azurerm_private_endpoint_connection.model_api_conn[count.index].private_service_connection.0.private_ip_address]
}