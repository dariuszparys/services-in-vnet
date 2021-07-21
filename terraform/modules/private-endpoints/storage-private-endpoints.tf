data "azurerm_storage_account" "shared" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
}

resource "azurerm_storage_account_network_rules" "firewall_rules" {
  resource_group_name = var.resource_group_name
  storage_account_name = data.azurerm_storage_account.shared.name

  default_action = "Deny"
  ip_rules = []
  virtual_network_subnet_ids = [ var.private_endpoints_subnet_id ]
  bypass = [ "AzureServices" ]
}

resource "azurerm_private_dns_zone" "sa_zone_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "sa_zone_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_blob_link" {
  name                  = "${var.resource_prefix}-link-blob"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_blob.name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_file_link" {
  name                  = "${var.resource_prefix}-link-file"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_file.name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_endpoint" "sa_pe_blob" {
  name                = "${var.resource_prefix}-sa-pe-blob-${var.resource_suffix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "${var.resource_prefix}-sa-psc-blob-${var.resource_suffix}"
    private_connection_resource_id = data.azurerm_storage_account.shared.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa_zone_blob.id]
  }  
}

resource "azurerm_private_endpoint" "sa_pe_file" {
  name                = "${var.resource_prefix}-sa-pe-file-${var.resource_suffix}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "${var.resource_prefix}-sa-psc-file-${var.resource_suffix}"
    private_connection_resource_id = data.azurerm_storage_account.shared.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-file"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa_zone_file.id]
  }  
}
