resource "azurerm_storage_account" "apps" {
  name                     = local.apps_storage_name
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "this" {
  name                = local.app_service_plan_elastic_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  kind                = "elastic"
  reserved            = true

  sku {
    tier = "ElasticPremium"
    size = "EP2"
  }

  tags = {
    environment = "${var.env_code}"
  }
}

locals {
  appSettingsDefault = {
    APPINSIGHTS_INSTRUMENTATIONKEY          = "${azurerm_application_insights.this.instrumentation_key}"
    APPLICATIONINSIGHTS_CONNECTION_STRING   = "InstrumentationKey=${azurerm_application_insights.this.instrumentation_key}"
    MODEL_API_FQDN                          = "${azurerm_app_service.modelapisvc.default_site_hostname}"
    https_only                              = true
    DOCKER_REGISTRY_SERVER_URL              = "https://${azurerm_container_registry.this.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME         = "${azurerm_container_registry.this.admin_username}"
    DOCKER_REGISTRY_SERVER_PASSWORD         = "${azurerm_container_registry.this.admin_password}"
    PYTHON_ENABLE_WORKER_EXTENSIONS         = "1"
  }

  appSettingsPlusVnet = {
    WEBSITE_DNS_SERVER                      = "168.63.129.16" // this is Azure DNS service for private zones
    WEBSITE_VNET_ROUTE_ALL                  = "1"  
  }
}


resource "azurerm_function_app" "coreapi" {
  name                       = local.coreapi_name
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.this.name
  app_service_plan_id        = azurerm_app_service_plan.this.id
  storage_account_name       = azurerm_storage_account.apps.name
  storage_account_access_key = azurerm_storage_account.apps.primary_access_key
  os_type                    = "linux"
  version                    = "~3"

  site_config {
    linux_fx_version = "python|3.8"
    use_32_bit_worker_process = false
    pre_warmed_instance_count = 1
  }

  app_settings = (merge(local.appSettingsDefault, local.appSettingsPlusVnet))  

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "${var.env_code}"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "apps_vnet" {
  #count          = var.deploy_to_vnet ? 1 : 0
  app_service_id = azurerm_function_app.coreapi.id
  subnet_id      = azurerm_subnet.apps.id
  depends_on     = [
    azurerm_function_app.coreapi,
    azurerm_subnet.apps
  ]
}


resource "azurerm_private_dns_zone" "websites_zone" {
  #count               = var.deploy_to_vnet ? 1 : 0
  name                = "privatelink.azurewebsites.net"
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "websites_zone_link" {
  #count                 = var.deploy_to_vnet ? 1 : 0
  name                  = "${local.resource_prefix}.websites_link"
  resource_group_name   = data.azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.websites_zone.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_endpoint" "core_api_pe" {
  #count               = var.deploy_to_vnet ? 1 : 0
  name                = "${local.resource_prefix}-core-api-pe-${local.seed_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml.id

  private_service_connection {
    name                           = "${local.resource_prefix}-core-api-psc-${local.seed_suffix}"
    private_connection_resource_id = azurerm_function_app.coreapi.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

}

data "azurerm_private_endpoint_connection" "core_api_conn" {
  #count                 = var.deploy_to_vnet ? 1 : 0  
  depends_on            = [azurerm_private_endpoint.core_api_pe]

  name                  = azurerm_private_endpoint.core_api_pe.name
  resource_group_name   = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_a_record" "core_api_dns_a_record" {
  #count                 = var.deploy_to_vnet ? 1 : 0  
  depends_on            = [azurerm_container_registry.this]

  name                  = lower(azurerm_function_app.coreapi.name)
  zone_name             = azurerm_private_dns_zone.websites_zone.name
  resource_group_name   = data.azurerm_resource_group.this.name
  ttl                   = 300
  records               = [data.azurerm_private_endpoint_connection.core_api_conn.private_service_connection.0.private_ip_address]
}