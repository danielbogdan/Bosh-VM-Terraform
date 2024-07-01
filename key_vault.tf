resource "azurerm_key_vault" "bosch_kvault" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.bosch-test.location
  resource_group_name         = azurerm_resource_group.bosch-test.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = true
#   # this is the access policy for Terraform itself; it is required to create future secrets
#   # if not configured, a 403 response is return when creating the resources
#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     key_permissions = [
#     ]

#     secret_permissions = [
#       "Get",
#       "List",
#       "Set",
#       "Delete",
#       "Purge",
#       "Recover"
#     ]
#   }

#   lifecycle {
#     ignore_changes = [access_policy]
#   }

}

data "azurerm_client_config" "current" {}

data "azurerm_role_definition" "key_vault_secrets_officer" {
  name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "terraform" {
  scope              = azurerm_key_vault.bosch_kvault.id
  role_definition_id = data.azurerm_role_definition.key_vault_secrets_officer.id
  principal_id       = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "vm_admin_passwords" {
  count        = var.vm_count
  name         = "vm-admin-password-${count.index}"
  value        = random_password.vm_admin_passwords[count.index].result
  key_vault_id = azurerm_key_vault.bosch_kvault.id

  # Ensure proper dependency on role assignment
  depends_on = [
    azurerm_role_assignment.terraform
  ]
 }

data "azurerm_key_vault_secret" "vm_admin_passwords" {
  count        = var.vm_count
  name         = "vm-admin-password-${count.index}"
  key_vault_id = azurerm_key_vault.bosch_kvault.id

  depends_on = [
    azurerm_key_vault_secret.vm_admin_passwords,
    azurerm_role_assignment.terraform
  ]
 }

output "vm_admin_passwords" {
  value     = data.azurerm_key_vault_secret.vm_admin_passwords[*].value
  sensitive = true
}
