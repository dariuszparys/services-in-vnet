data "azurerm_function_app" "services" {
  name                          = var.function_app_name
  resource_group_name           = var.resource_group_name
}

data "azurerm_app_service" "services" {
  name                          = var.app_service_name
  resource_group_name           = var.resource_group_name
}

resource "azurerm_app_service_virtual_network_swift_connection" "apps_vnet" {
  app_service_id = data.azurerm_function_app.services.id
  subnet_id      = var.services_subnet_id
}


resource "azurerm_private_dns_zone" "websites_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "websites_zone_link" {
  name                  = "${var.resource_prefix}.websites-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.websites_zone.name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_endpoint" "core_api_pe" {
  name                = "${var.resource_prefix}-core-api-pe-${var.resource_suffix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "${var.resource_prefix}-core-api-psc-${var.resource_suffix}"
    private_connection_resource_id = data.azurerm_function_app.services.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-websites"
    private_dns_zone_ids = [azurerm_private_dns_zone.websites_zone.id]
  }
}

resource "azurerm_private_endpoint" "model_api_pe" {
  name                = "${var.resource_prefix}-model-api-pe-${var.resource_suffix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "${var.resource_prefix}-model-api-psc-${var.resource_suffix}"
    private_connection_resource_id = data.azurerm_app_service.services.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-websites"
    private_dns_zone_ids = [azurerm_private_dns_zone.websites_zone.id]
  }
}
