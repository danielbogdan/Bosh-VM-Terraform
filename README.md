# Terraform Variables for Azure Deployment

This Terraform configuration leverages various variables to customize deployments in Azure. Below is a detailed explanation of each variable and its configuration.

## 🌟 Required Variables

### `subscription_id`
- **Type:** `string`
- **Sensitive:** Yes
- **Description:** Azure subscription ID where the resources will be deployed.

### `tenant_id`
- **Type:** `string`
- **Sensitive:** Yes
- **Description:** Azure Active Directory tenant ID.

### `client_id`
- **Type:** `string`
- **Sensitive:** Yes
- **Description:** Client ID (service principal) for authenticating to Azure.

### `client_secret`
- **Type:** `string`
- **Sensitive:** Yes
- **Description:** Client secret associated with the client ID for Azure authentication.

### `vm_admin_user`
- **Type:** `string`
- **Sensitive:** Yes
- **Description:** Administrator username for the VMs.

### `address_space`
- **Type:** `list(any)`
- **Description:** Address space for the Virtual Network (VNet) where VMs will reside.

### `infra_subnet`
- **Type:** `list(any)`
- **Description:** Subnet configuration within the VNet for infrastructure components.

## ⚙️ Optional Variables with Defaults

### `resources_location`
- **Type:** `string`
- **Description:** Location where Azure resources will be deployed.
- **Default:** `"West Europe"`

### `key_vault_name`
- **Type:** `string`
- **Description:** Name of the Azure Key Vault to store secrets.
- **Default:** `"bosh-vm-keyvault"`

### `vm_count`
- **Type:** `number`
- **Description:** Number of VMs to create.
- **Default:** `3`
- **Validation:** Must be between 2 and 100.

### `vm_flavor`
- **Type:** `string`
- **Description:** Flavor (size) of the VMs.
- **Default:** `"Standard_B2s"`

### `vm_image`
- **Type:** `string`
- **Description:** OS image for the VMs.
- **Default:** `"22_04-lts"`

## 🏷️ Local Variables

### `env_project`
- **Value:** `"test"`
- **Description:** Project environment identifier.

### `env_name`
- **Value:** `"bosh"`
- **Description:** Environment name.

## 📌 Variable Usage Guidelines

- Ensure sensitive variables (`subscription_id`, `tenant_id`, `client_id`, `client_secret`, `vm_admin_user`) are securely managed and not exposed in version control.
- Adjust `vm_count`, `vm_flavor`, `vm_image`, and other configurable variables according to your specific deployment requirements.

---

