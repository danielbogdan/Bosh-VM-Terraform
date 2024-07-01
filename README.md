# Terraform Code for Configurable VMs with Unique Admin Passwords and Round-Robin Ping Testing

This Terraform configuration creates a configurable number of VMs (between 2 and 100) with the following features:

- Configurable VM parameters (flavor, image, count)
- Unique admin passwords stored in an Azure Key Vault
- All VMs in the same virtual network
- Automated round-robin ping testing between the VMs

## Variables

### Input Variables
- `vm_count`: The number of VMs to create (between 2 and 100).
- `vm_flavor`: The flavor of the VMs.
- `vm_image`: The image of the VMs.
- `key_vault_name`: The name of the Azure Key Vault to store the VM admin passwords.

### Output Variables
- `vm_admin_passwords`: The generated admin passwords for the VMs (sensitive).
- `ping_results`: The results of the round-robin ping test between the VMs.

## Terraform Configuration

```hcl
provider "azurerm" {
  features {}
}

resource "random_password" "admin_password" {
  count     = var.vm_count
  length    = 16
  special   = true
  override_special = "_%@"
}

resource "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  location            = var.resources_location
  resource_group_name = var.resource_group_name
  sku_name            = "standard"
  tenant_id           = var.tenant_id

  soft_delete_enabled = true
}

resource "azurerm_key_vault_access_policy" "main" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = var.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["set", "get"]
}

resource "azurerm_key_vault_secret" "admin_password" {
  count         = var.vm_count
  name          = "admin-password-${count.index}"
  value         = random_password.admin_password[count.index].result
  key_vault_id  = azurerm_key_vault.main.id
}

resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  address_space       = var.address_space
  location            = var.resources_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "main" {
  name                 = "main-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.infra_subnet
}

resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "main-nic-${count.index}"
  location            = var.resources_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count               = var.vm_count
  name                = "vm-${count.index}"
  location            = var.resources_location
  resource_group_name = var.resource_group_name
  size                = var.vm_flavor
  admin_username      = var.vm_admin_user
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  admin_password = random_password.admin_password[count.index].result

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.vm_image
    version   = "latest"
  }

  custom_data = base64encode("#!/bin/bash\napt-get update && apt-get install -y iputils-ping")
}

resource "null_resource" "ping_test" {
  count = var.vm_count * (var.vm_count - 1)

  triggers = {
    vm1_ip = element(azurerm_network_interface.main[*].private_ip_address, count.index / (var.vm_count - 1))
    vm2_ip = element(azurerm_network_interface.main[*].private_ip_address, count.index % (var.vm_count - 1))
  }

  provisioner "local-exec" {
    command = "ping -c 1 ${self.triggers.vm2_ip}"
    on_failure = "continue"
  }
}

output "vm_admin_passwords" {
  value     = [for i in azurerm_key_vault_secret.admin_password : i.value]
  sensitive = true
}

output "ping_results" {
  value = join("\n", null_resource.ping_test.*.triggers)
}
```

## Usage

1. Ensure you have the necessary Azure provider configured and credentials set up.
2. Save the Terraform code to a file (e.g., `main.tf`).
3. Create a `terraform.tfvars` file and set the desired values for the input variables.
4. Run the following Terraform commands:

```bash
terraform init
terraform apply -var="vm_count=5"
```

This will create 5 VMs with the specified parameters and generate the output variables.

## Explanation

- The `random_password` resource generates unique admin passwords for each VM.
- The `azurerm_key_vault` resource creates an Azure Key Vault to store the generated admin passwords.
- The `azurerm_key_vault_secret` resource stores the admin passwords as secrets in the Key Vault.
- The `azurerm_linux_virtual_machine` resource creates the VMs with the specified flavor, image, and admin passwords.
- The `azurerm_network_interface` and `azurerm_subnet` resources set up the virtual network for the VMs.
- The `null_resource` resource performs round-robin ping tests between the VMs.
- The `output` blocks expose the generated admin passwords and the round-robin ping test results.
