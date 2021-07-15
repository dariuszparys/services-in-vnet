resource "azurerm_linux_virtual_machine_scale_set" "this" {
  count                           = var.deploy_to_vnet ? 1 : 0  
  name                            = local.vmss_name
  resource_group_name             = data.azurerm_resource_group.this.name
  location                        = var.location
  sku                             = "Standard_DS1_v2"
  instances                       = 0
  admin_username                  = var.vmss_admin_user
  admin_password                  = random_password.password.result
  disable_password_authentication = false

  source_image_id                 = var.source_image_id
  
  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.aml[count.index].id
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      instances,
      tags
    ]
  }

  tags = {
    environment = "${var.env_code}"
  }

  depends_on = [
    azurerm_virtual_network.this
  ]
}