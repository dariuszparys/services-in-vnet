locals {
  application_gateway_name            = "${local.resource_prefix}-gateway-${local.seed_suffix}"
  application_gateway_ip_config_name  = "${local.resource_prefix}-gateway-ip-configuration"
  coreapi_ip_name             = "${local.resource_prefix}-coreapi-ip"
  backend_address_pool_name           = "${local.resource_prefix}-beap"
  frontend_port_name                  = "${local.resource_prefix}-feport"
  frontend_ip_configuration_name      = "${local.resource_prefix}-feip"
  http_setting_name                   = "${local.resource_prefix}-be-htst"
  listener_name                       = "${local.resource_prefix}-httplstn"
  request_routing_rule_name           = "${local.resource_prefix}-rqrt"
  redirect_configuration_name         = "${local.resource_prefix}-rdrcfg"
}

resource "azurerm_public_ip" "coreapi_ip" {
  count               = var.deploy_to_vnet ? 1 : 0
  name                = local.coreapi_ip_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "network" {
  count               = var.deploy_to_vnet ? 1 : 0
  name                = local.application_gateway_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location

  sku {
    name     = "Standard_V2"
    tier     = "Standard_V2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = local.application_gateway_ip_config_name
    subnet_id = azurerm_subnet.landing[count.index].id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.coreapi_ip[count.index].id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = [
      azurerm_app_service.modelapisvc.default_site_hostname
    ]
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 240
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  depends_on = [
    azurerm_function_app.coreapi
  ]
}