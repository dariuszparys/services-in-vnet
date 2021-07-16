resource "azurerm_key_vault" "this" {
  name                       = local.keyvault_name
  resource_group_name        = data.azurerm_resource_group.this.name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.this.tenant_id
  purge_protection_enabled   = true
  soft_delete_enabled        = true
  sku_name                   = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.this.tenant_id
    object_id = data.azurerm_client_config.this.object_id

    key_permissions = [
      "get",
      "create",
      "delete",
      "list",
      "restore",
      "recover",
      "unwrapkey",
      "wrapkey",
      "purge",
      "encrypt",
      "decrypt",
      "sign",
      "verify",
      "update"
    ]

    secret_permissions = [
      "set",
      "get",
      "list",
      "delete"
    ]
  }

  dynamic "network_acls" {
    for_each = [1]
    content {
      default_action = "Deny"
      ip_rules = []
      virtual_network_subnet_ids = [ azurerm_subnet.aml.id ]
      bypass = "AzureServices"
    }
  }

  lifecycle {
    ignore_changes = [access_policy]
  }

  tags = {
    environment = "${var.env_code}"
  }  
}

resource "azurerm_private_dns_zone" "kv_zone" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_zone_link" {
  #count                 = var.deploy_to_vnet ? 1 : 0  
  name                  = "${local.resource_prefix}_link_kv"
  resource_group_name   = data.azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.kv_zone.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_endpoint" "kv_pe" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  name                = "${local.resource_prefix}-kv-pe-${local.seed_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml.id

  private_service_connection {
    name                           = "${local.resource_prefix}-kv-psc-${local.seed_suffix}"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

data "azurerm_private_endpoint_connection" "kv_conn" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  depends_on          = [azurerm_private_endpoint.kv_pe]

  name                = azurerm_private_endpoint.kv_pe.name
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_a_record" "kv_pe_dns_a_record" {
  #count               = var.deploy_to_vnet ? 1 : 0  
  depends_on          = [azurerm_key_vault.this]

  name                = lower(azurerm_key_vault.this.name)
  zone_name           = azurerm_private_dns_zone.kv_zone.name
  resource_group_name = data.azurerm_resource_group.this.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.kv_conn.private_service_connection.0.private_ip_address]
}