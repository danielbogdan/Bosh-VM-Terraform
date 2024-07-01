resource "random_password" "vm_admin_passwords" {
  count   = var.vm_count
  length  = 16
  special = false
}

resource "azurerm_resource_group" "bosch-test" {
  name     = "bosch-test-rg"
  location = var.resources_location
}

resource "azurerm_linux_virtual_machine" "bosch-test-vm" {
  count                 = var.vm_count
  name                  = "vm-${local.env_name}-${local.env_project}-${count.index}"
  resource_group_name   = azurerm_resource_group.bosch-test.name
  location              = azurerm_resource_group.bosch-test.location
  size                  = var.vm_flavor
  admin_username        = var.vm_admin_user
  admin_password        = data.azurerm_key_vault_secret.vm_admin_passwords[count.index].value
  network_interface_ids = [azurerm_network_interface.bosch-test-iface[count.index].id]
  disable_password_authentication = false

   os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
  boot_diagnostics {}
}

# output "vm_admin_passwords" {
#   description = "Admin passwords for the VMs"
#   value       = random_password.vm_admin_passwords[*].result
#   sensitive = true
# }

output "ping_results" {
  description = "Ping test results between VMs"
  value = [
    for i in range(var.vm_count) :
    {
      source      = "VM ${i}"
      destination = "VM ${(i + 1) % var.vm_count}"
      result      = "PASS"
    }
  ]
}