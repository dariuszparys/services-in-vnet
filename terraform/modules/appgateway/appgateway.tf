locals {
  application_gateway_name            = "${var.resource_prefix}-gateway-${var.resource_suffix}"
  application_gateway_ip_config_name  = "${var.resource_prefix}-gateway-ip-cfg-${var.resource_suffix}"
  function_app_ip_name                = "${var.resource_prefix}-functionapp-ip-${var.resource_suffix}"
  backend_address_pool_name           = "${var.resource_prefix}-beap-${var.resource_suffix}"
  frontend_port_name                  = "${var.resource_prefix}-feport-${var.resource_suffix}"
  frontend_ip_configuration_name      = "${var.resource_prefix}-feip-${var.resource_suffix}"
  http_setting_name                   = "${var.resource_prefix}-be-htst-${var.resource_suffix}"
  listener_name                       = "${var.resource_prefix}-httplstn-${var.resource_suffix}"
  request_routing_rule_name           = "${var.resource_prefix}-rqrt-${var.resource_suffix}"
  redirect_configuration_name         = "${var.resource_prefix}-rdrcfg-${var.resource_suffix}"
}

resource "azurerm_public_ip" "entry" {
  name                = local.function_app_ip_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "network" {
  name                = local.application_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    name     = "Standard_V2"
    tier     = "Standard_V2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = local.application_gateway_ip_config_name
    subnet_id = var.gateway_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.entry.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = [
      # azurerm_app_service.modelapisvc.default_site_hostname
      var.app_service_fqdns
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
}