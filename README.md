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
terraform plan -var="vm_count=5" -out bosh.tfplan
terraform apply "bosh.tfplan"
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
