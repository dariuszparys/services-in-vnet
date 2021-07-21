resource "azurerm_virtual_network" "shared" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = var.vnet_address_space
  tags = {
    environment = var.env_code
  }                        
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = var.private_endpoints_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.shared.name
  address_prefixes     = [var.private_endpoints_subnet_prefix]
  service_endpoints = [ "Microsoft.ContainerRegistry",
                        "Microsoft.Storage",
                        "Microsoft.Web"]
  enforce_private_link_endpoint_network_policies = true    
}

resource "azurerm_subnet" "services" {
  name                 = var.services_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.shared.name
  address_prefixes     = [var.services_subnet_prefix]
  delegation {
    name = "services_subnet_delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }                      
}

resource "azurerm_subnet" "gateway" {
  name                 = var.gateway_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.shared.name
  address_prefixes     = [var.gateway_subnet_prefix]
  service_endpoints = [ "Microsoft.Web"]
}  
