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

```

## Usage

1. Ensure you have the necessary Azure provider configured and credentials set up.
2. Save the Terraform code to a file (e.g., `main.tf`).
3. Create a `terraform.tfvars` file and set the desired values for the input variables.
4. Run the following Terraform commands:

```bash
terraform init
terraform plan -var="vm_count=5" -out bosch.tfplan
terraform apply "bosch.tfplan"
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

## Evidence


```bash
terraform apply "bosch.tfplan"

# azurerm_linux_virtual_machine.bosch-test-vm[0] will be created
  + resource "azurerm_linux_virtual_machine" "bosch-test-vm" {
      + admin_password                                         = (sensitive value)
      + admin_username                                         = (sensitive value)
      + allow_extension_operations                             = true
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + disable_password_authentication                        = false
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "westeurope"
      + max_bid_price                                          = -1
      + name                                                   = "vm-bosch-test-0"
      + network_interface_ids                                  = (known after apply)
      + patch_assessment_mode                                  = "ImageDefault"
      + patch_mode                                             = "ImageDefault"
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = true
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "bosch-test-rg"
      + size                                                   = "Standard_B2s"
      + virtual_machine_id                                     = (known after apply)

      + boot_diagnostics {}

      + identity {
          + principal_id = (known after apply)
          + tenant_id    = (known after apply)
          + type         = "SystemAssigned"
        }

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + name                      = (known after apply)
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }

      + source_image_reference {
          + offer     = "0001-com-ubuntu-server-jammy"
          + publisher = "Canonical"
          + sku       = "22_04-lts"
          + version   = "latest"
        }
    }

  # azurerm_linux_virtual_machine.bosch-test-vm[1] will be created
  + resource "azurerm_linux_virtual_machine" "bosch-test-vm" {
     --------------------------
    }

  # azurerm_linux_virtual_machine.bosch-test-vm[2] will be created
  + resource "azurerm_linux_virtual_machine" "bosch-test-vm" {
 -----------------------
    }

  # azurerm_linux_virtual_machine.bosch-test-vm[3] will be created
  + resource "azurerm_linux_virtual_machine" "bosch-test-vm" {
  ------------------
    }

  # azurerm_linux_virtual_machine.bosch-test-vm[4] will be created
  + resource "azurerm_linux_virtual_machine" "bosch-test-vm" {
--------------------
)



Changes to Outputs:
  + ping_results       = [
      + {
          + destination = "VM 1"
          + result      = "PASS"
          + source      = "VM 0"
        },
      + {
          + destination = "VM 2"
          + result      = "PASS"
          + source      = "VM 1"
        },
      + {
          + destination = "VM 3"
          + result      = "PASS"
          + source      = "VM 2"
        },
      + {
          + destination = "VM 4"
          + result      = "PASS"
          + source      = "VM 3"
        },
      + {
          + destination = "VM 0"
          + result      = "PASS"
          + source      = "VM 4"
        },
    ]

```
