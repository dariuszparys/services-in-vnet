resource "azurerm_storage_account" "aml" {
  name                = local.storage_name
  resource_group_name = azurerm_resource_group.this.name

  location                  = azurerm_resource_group.this.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"

  tags = {
    environment = "${var.env_code}"
  }
}

resource "azurerm_storage_account_network_rules" "firewall_rules" {
  resource_group_name = azurerm_resource_group.this.name
  storage_account_name = azurerm_storage_account.aml.name

  default_action = "Deny"
  ip_rules = [ ]
  virtual_network_subnet_ids = [ azurerm_subnet.aml.id ]
  bypass = [ "AzureServices" ]
  
  depends_on = [
    azurerm_machine_learning_workspace.this
  ]
}

resource "azurerm_private_dns_zone" "sa_zone_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone" "sa_zone_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_blob_link" {
  name                  = "${local.resource_prefix}_link_blob"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_blob.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_file_link" {
  name                  = "${local.resource_prefix}_link_file"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_file.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_endpoint" "sa_pe_blob" {
  name                = "${local.resource_prefix}-sa-pe-blob-${local.seed_suffix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml.id

  private_service_connection {
    name                           = "${local.resource_prefix}-sa-psc-blob-${local.seed_suffix}"
    private_connection_resource_id = azurerm_storage_account.aml.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa_zone_blob.id]
  }  
}

resource "azurerm_private_endpoint" "sa_pe_file" {
  name                = "${local.resource_prefix}-sa-pe-file-${local.seed_suffix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml.id

  private_service_connection {
    name                           = "${local.resource_prefix}-sa-psc-file-${local.seed_suffix}"
    private_connection_resource_id = azurerm_storage_account.aml.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-file"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa_zone_file.id]
  }  
}
