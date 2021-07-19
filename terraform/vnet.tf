resource "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location  
  address_space       = var.vnet_address_space
  tags = {
    environment = "${var.env_code}"
  }                        
}

resource "azurerm_subnet" "landing" {
  name                 = local.landing_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.landing_subnet_prefix]
  service_endpoints = [ "Microsoft.Web"]
}                

resource "azurerm_subnet" "aml" {
  name                 = local.aml_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.aml_subnet_prefix]
  service_endpoints = [ "Microsoft.KeyVault",
                        "Microsoft.ContainerRegistry",
                        "Microsoft.Storage",
                        "Microsoft.Web"]
  enforce_private_link_endpoint_network_policies = true                        
}

resource "azurerm_subnet" "compute" {
  name                 = local.compute_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.compute_subnet_prefix]
  service_endpoints = [ "Microsoft.KeyVault",
                        "Microsoft.ContainerRegistry",
                        "Microsoft.Storage"]
  enforce_private_link_service_network_policies = false
  enforce_private_link_endpoint_network_policies = false
}

resource "azurerm_subnet" "apps" {
  name                 = local.apps_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.apps_subnet_prefix]
  
  delegation {
    name = "apps_subnet_delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

