resource "azurerm_container_registry" "this" {
  name                          = local.container_registry_name
  resource_group_name           = data.azurerm_resource_group.this.name
  location                      = var.location
  sku                           = "Premium"
  admin_enabled                 = true 


  network_rule_set {
    default_action = "Deny"
    virtual_network = [
      {
        action = "Allow",
        subnet_id = azurerm_subnet.aml.id
      }
    ]
  }

  tags = {
    environment = "${var.env_code}"
  }

  depends_on = [
    azurerm_subnet.aml
  ]
}

resource "azurerm_private_dns_zone" "acr_zone" {
  name                = "privatelink.azurecr.io"
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_zone_link" {
  name                  = "${local.resource_prefix}.acr_link"
  resource_group_name   = data.azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.acr_zone.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${local.resource_prefix}-acr-pe-${local.seed_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml.id

  private_service_connection {
    name                           = "${local.resource_prefix}-acr-psc-${local.seed_suffix}"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}

data "azurerm_private_endpoint_connection" "acr_conn" {
  depends_on          = [azurerm_private_endpoint.acr_pe]

  name                = azurerm_private_endpoint.acr_pe.name
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "null_resource" "dns_acr_fix" {
  depends_on = [azurerm_private_endpoint.acr_pe]

  provisioner "local-exec" {
    command = "./dns-acr-fix.sh"

    environment = {
      RESOURCE_GROUP=data.azurerm_resource_group.this.name
      REGISTRY_LOCATION="westeurope"
      REGISTRY_NAME=azurerm_container_registry.this.name
      PRIVATE_ENDPOINT_NAME=azurerm_private_endpoint.acr_pe.name
    }
  }
}