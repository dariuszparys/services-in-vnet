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

# The az acr build command can also be applied with a --no-wait option
# It is just not inserted here to have the first time experience flawless
# as the services might still wait for pulling the containers currently
# build asynchronously
resource "null_resource" "deployment" {
  provisioner "local-exec" {
    command = <<-EOT
      az acr login -n ${azurerm_container_registry.shared.name}
      az acr build -t ${azurerm_container_registry.shared.login_server}/${var.functionapp_image_name}:${var.common_image_tag} -r ${azurerm_container_registry.shared.name} ../../src/call_any_url/
      az acr build -t ${azurerm_container_registry.shared.login_server}/${var.appservice_image_name}:${var.common_image_tag} -r ${azurerm_container_registry.shared.name} ../../src/flask_app_service/
    EOT 
  }

  depends_on = [ azurerm_container_registry.shared ]
}