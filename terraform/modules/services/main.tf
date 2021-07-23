resource "azurerm_app_service_plan" "services" {
  name                = var.app_service_plan_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }

  tags = {
    environment = var.env_code
  }
}

locals {
  appSettingsDefault = {
    APPINSIGHTS_INSTRUMENTATIONKEY          = var.app_insights_key
    APPLICATIONINSIGHTS_CONNECTION_STRING   = "InstrumentationKey=${var.app_insights_key}"
    https_only                              = true
    DOCKER_REGISTRY_SERVER_URL              = var.container_registry_url
    DOCKER_REGISTRY_SERVER_USERNAME         = var.container_registry_username
    DOCKER_REGISTRY_SERVER_PASSWORD         = var.container_registry_password
    PYTHON_ENABLE_WORKER_EXTENSIONS         = "1"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE     = false
    FUNCTION_APP_EDIT_MODE                  = "readOnly"
  }

  appSettingsPlusVnet = {
    WEBSITE_CONTENTOVERVNET                 = "1"
    WEBSITE_DNS_SERVER                      = "168.63.129.16" // this is Azure DNS service for private zones
    WEBSITE_VNET_ROUTE_ALL                  = "1"
  }
}

resource "azurerm_function_app" "services" {
  name                       = var.function_app_name
  location                   = var.resource_group_location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.services.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  os_type                    = "linux"
  version                    = "~3"

  site_config {
    linux_fx_version = "DOCKER|${var.container_registry_url}/${var.functionapp_image_name}:${var.common_image_tag}"
    pre_warmed_instance_count = 1
    always_on = true
  }

  app_settings = (
                  var.enable_vnet
                    ? merge(local.appSettingsDefault, local.appSettingsPlusVnet)
                    : local.appSettingsDefault
                 )  

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.env_code
  }
}

resource "azurerm_app_service" "services" {
  name                = var.app_service_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.services.id

  site_config {
    linux_fx_version = "DOCKER|${var.container_registry_url}/${var.appservice_image_name}:${var.common_image_tag}"
    always_on = true
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = var.app_insights_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = "InstrumentationKey=${var.app_insights_key}"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    DOCKER_REGISTRY_SERVER_URL            = "https://${var.container_registry_url}"
    DOCKER_REGISTRY_SERVER_USERNAME       = var.container_registry_username
    DOCKER_REGISTRY_SERVER_PASSWORD       = var.container_registry_password
  }

  identity {
    type = "SystemAssigned"
  }
}
