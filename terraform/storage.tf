resource "azurerm_storage_account" "aml" {
  name                = local.storage_name
  resource_group_name = data.azurerm_resource_group.this.name

  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"

  tags = {
    environment = "${var.env_code}"
  }
}

resource "azurerm_storage_account_network_rules" "firewall_rules" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  resource_group_name = data.azurerm_resource_group.this.name
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
  #count               = var.deploy_to_vnet ? 1 : 0  
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone" "sa_zone_file" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_blob_link" {
  #count                 = var.deploy_to_vnet ? 1 : 0  
  name                  = "${local.resource_prefix}_link_blob"
  resource_group_name   = data.azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_blob.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_file_link" {
  #count                 = var.deploy_to_vnet ? 1 : 0  
  name                  = "${local.resource_prefix}_link_file"
  resource_group_name   = data.azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_file.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_endpoint" "sa_pe_blob" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  name                = "${local.resource_prefix}-sa-pe-blob-${local.seed_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml.id

  private_service_connection {
    name                           = "${local.resource_prefix}-sa-psc-blob-${local.seed_suffix}"
    private_connection_resource_id = azurerm_storage_account.aml.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "sa_pe_file" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  name                = "${local.resource_prefix}-sa-pe-file-${local.seed_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml.id

  private_service_connection {
    name                           = "${local.resource_prefix}-sa-psc-file-${local.seed_suffix}"
    private_connection_resource_id = azurerm_storage_account.aml.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}

data "azurerm_private_endpoint_connection" "sa_pe_file_conn" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  depends_on          = [azurerm_private_endpoint.sa_pe_file]

  name                = azurerm_private_endpoint.sa_pe_file.name
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_a_record" "sa_pe_file_dns_a_record" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  depends_on          = [azurerm_storage_account.aml]

  name                = lower(azurerm_storage_account.aml.name)
  zone_name           = azurerm_private_dns_zone.sa_zone_file.name
  resource_group_name = data.azurerm_resource_group.this.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.sa_pe_file_conn.private_service_connection.0.private_ip_address]
}

data "azurerm_private_endpoint_connection" "sa_pe_blob_conn" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  depends_on          = [azurerm_private_endpoint.sa_pe_blob]

  name                = azurerm_private_endpoint.sa_pe_blob.name
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_a_record" "sa_pe_blob_dns_a_record" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  depends_on          = [azurerm_storage_account.aml]

  name                = lower(azurerm_storage_account.aml.name)
  zone_name           = azurerm_private_dns_zone.sa_zone_blob.name
  resource_group_name = data.azurerm_resource_group.this.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.sa_pe_blob_conn.private_service_connection.0.private_ip_address]
}
