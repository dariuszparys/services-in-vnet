terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.68.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

data "azurerm_client_config" "this" {
}

resource "azurerm_resource_group" "this" {
  name      = var.resource_group_name
  location  = var.location
}

module vnet {
  count  = var.enable_vnet ? 1 : 0
  source = "../modules/vnet"

  env_code                        = var.env_code

  resource_group_name             = azurerm_resource_group.this.name
  resource_group_location         = azurerm_resource_group.this.location

  vnet_name                       = local.vnet_name
  vnet_address_space              = ["10.0.0.0/16"]

  private_endpoints_subnet_name   = "PrivateEndpointsSubnet"
  private_endpoints_subnet_prefix = "10.0.1.0/24"

  services_subnet_name            = "ServicesSubnet"
  services_subnet_prefix          = "10.0.2.0/24"

  gateway_subnet_name             = "EntrySubnet"
  gateway_subnet_prefix           = "10.0.3.0/24"
}

module acr {
  count = 1
  source = "../modules/acr"

  env_code                      = var.env_code

  resource_group_name           = azurerm_resource_group.this.name
  resource_group_location       = azurerm_resource_group.this.location

  container_registry_name       = local.container_registry_name
  private_endpoints_subnet_id   = var.enable_vnet ? module.vnet[count.index].private_endpoints_subnet_id : ""

  enable_vnet                   = var.enable_vnet
}

module appinsights {
  source = "../modules/appinsights"

  env_code                      = var.env_code

  resource_group_name           = azurerm_resource_group.this.name
  resource_group_location       = azurerm_resource_group.this.location

  app_insights_name             = local.app_insights_name
}

module storage {
  source = "../modules/storage"

  env_code                      = var.env_code

  resource_group_name           = azurerm_resource_group.this.name
  resource_group_location       = azurerm_resource_group.this.location

  storage_account_name          = local.storage_name
}

module services {
  count = 1
  source = "../modules/services"

  env_code                    = var.env_code

  resource_group_name         = azurerm_resource_group.this.name
  resource_group_location     = azurerm_resource_group.this.location

  app_service_plan_name       = local.app_service_plan_name
  function_app_name           = local.function_app_name
  app_service_name            = local.app_service_name
  app_insights_key            = module.appinsights.instrumentation_key
  storage_account_name        = module.storage.storage_account_name
  storage_account_access_key  = module.storage.storage_account_access_key
  container_registry_url      = module.acr[count.index].container_registry_login_server
  container_registry_username = module.acr[count.index].container_registry_username
  container_registry_password = module.acr[count.index].container_registry_password

  enable_vnet                 = var.enable_vnet
}

module private_endpoints {
  count  = var.enable_vnet ? 1 : 0
  source = "../modules/private-endpoints"

  env_code                      = var.env_code

  resource_group_name           = azurerm_resource_group.this.name
  resource_group_location       = azurerm_resource_group.this.location

  resource_prefix               = local.resource_prefix
  resource_suffix               = local.seed_suffix

  container_registry_name       = local.container_registry_name
  storage_account_name          = local.storage_name
  private_endpoints_subnet_id   = module.vnet[count.index].private_endpoints_subnet_id
  services_subnet_id            = module.vnet[count.index].services_subnet_id
  virtual_network_id            = module.vnet[count.index].virtual_network_id

  function_app_name             = local.function_app_name
  app_service_name              = local.app_service_name

  depends_on = [module.vnet, module.acr, module.storage, module.services]
}

module appgateway {
  count  = var.enable_vnet ? 1 : 0
  source = "../modules/appgateway"

  env_code                      = var.env_code

  resource_group_name           = azurerm_resource_group.this.name
  resource_group_location       = azurerm_resource_group.this.location

  resource_prefix               = local.resource_prefix
  resource_suffix               = local.seed_suffix

  gateway_subnet_id             = module.vnet[count.index].gateway_subnet_id
  app_service_fqdns             = module.services[count.index].appservice_url

  enable_vnet                   = var.enable_vnet

  depends_on = [module.private_endpoints]
}
