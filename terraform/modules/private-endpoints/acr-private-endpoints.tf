data "azurerm_container_registry" "shared" {
  name                          = var.container_registry_name
  resource_group_name           = var.resource_group_name
}

resource "azurerm_private_dns_zone" "acr_zone" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_zone_link" {
  name                  = "${var.resource_prefix}.acr-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr_zone.name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${var.resource_prefix}-acr-pe-${var.resource_suffix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "${var.resource_prefix}-acr-psc-${var.resource_suffix}"
    private_connection_resource_id = data.azurerm_container_registry.shared.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-acr"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr_zone.id]
  }
}
