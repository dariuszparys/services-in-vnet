resource "azurerm_machine_learning_workspace" "this" {
  name                    = local.workspace_name
  resource_group_name     = data.azurerm_resource_group.this.name
  location                = var.location
  application_insights_id = azurerm_application_insights.this.id
  key_vault_id            = azurerm_key_vault.this.id
  storage_account_id      = azurerm_storage_account.aml.id
  container_registry_id   = azurerm_container_registry.this.id

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "${var.env_code}"
  }
}

resource "azurerm_private_dns_zone" "ws_zone_api" {
  count               = var.deploy_to_vnet ? 1 : 0  
  name                = "privatelink.api.azureml.ms"
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone" "ws_zone_notebooks" {
  count               = var.deploy_to_vnet ? 1 : 0  
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "ws_zone_api_link" {
  count                 = var.deploy_to_vnet ? 1 : 0  
  name                  = "${local.resource_prefix}_link_api"
  resource_group_name   = data.azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.ws_zone_api[count.index].name
  virtual_network_id    = azurerm_virtual_network.this[count.index].id
}

resource "azurerm_private_dns_zone_virtual_network_link" "ws_zone_notebooks_link" {
  count                 = var.deploy_to_vnet ? 1 : 0  
  name                  = "${local.resource_prefix}_link_notebooks"
  resource_group_name   = data.azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.ws_zone_notebooks[count.index].name
  virtual_network_id    = azurerm_virtual_network.this[count.index].id
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "ws_pe" {
  count               = var.deploy_to_vnet ? 1 : 0  
  name                = "${local.resource_prefix}-ws-pe-${local.seed_suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml[count.index].id

  private_service_connection {
    name                           = "${local.resource_prefix}-ws-psc-${local.seed_suffix}"
    private_connection_resource_id = azurerm_machine_learning_workspace.this.id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }
  # Add Private Link after we configured the workspace and attached AKS
  depends_on = [azurerm_machine_learning_workspace.this]
}

data "azurerm_private_endpoint_connection" "ws_conn" {
  count               = var.deploy_to_vnet ? 1 : 0  
  depends_on          = [azurerm_private_endpoint.ws_pe]

  name                = azurerm_private_endpoint.ws_pe[count.index].name
  resource_group_name = data.azurerm_resource_group.this.name
}

resource "null_resource" "dns_aml_fix" {
  count      = var.deploy_to_vnet ? 1 : 0  
  depends_on = [azurerm_private_endpoint.ws_pe]

  provisioner "local-exec" {
    command = "./dns-aml-fix.sh"

    environment = {
      RESOURCE_GROUP=data.azurerm_resource_group.this.name
      RESOURCE_LOCATION="westeurope"
      PRIVATE_ENDPOINT_NAME=azurerm_private_endpoint.ws_pe[count.index].name
      AML_WORKSPACE_NAME=azurerm_machine_learning_workspace.this.name
    }
  }
}