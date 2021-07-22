resource "azurerm_container_registry" "shared" {
  name                          = var.container_registry_name
  resource_group_name           = var.resource_group_name
  location                      = var.resource_group_location
  sku                           = "Premium"
  admin_enabled                 = true

  dynamic "network_rule_set" {
    for_each = var.enable_vnet ? [1] : []
    content {
      default_action = "Deny"
      virtual_network = [
        {
          action = "Allow",
          subnet_id = var.private_endpoints_subnet_id
        }
      ]
    }
  }

  dynamic "network_rule_set" {
    for_each = var.enable_vnet ? [] : [1]
    content {
      default_action = "Allow"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.env_code
  }  
}

resource "null_resource" "deployment" {
  provisioner "local-exec" {
    command = <<-EOT
      az acr login -n ${azurerm_container_registry.shared.name}
      az acr build --no-wait -t ${azurerm_container_registry.shared.login_server}/functionapp:latest -r ${azurerm_container_registry.shared.name} ../../src/call_any_url/
      az acr build --no-wait -t ${azurerm_container_registry.shared.login_server}/appservice:latest -r ${azurerm_container_registry.shared.name} ../../src/flask_app_service/
    EOT 
  }

  depends_on = [ azurerm_container_registry.shared ]
}