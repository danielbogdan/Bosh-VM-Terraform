variable "resources_location" {
  type    = string
  default = "West Europe"
}

variable "subscription_id" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

locals {
  env_project = "test"
  env_name    = "bosch"
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
  default     = "bosch-vm-keyvault"
}

variable "vm_admin_user" {
  type      = string
  sensitive = true
}

variable "address_space" {
  type        = list(any)
  description = "VNet address space"
}

variable "infra_subnet" {
  type        = list(any)
  description = "VNet address subnet"
}

variable "vm_count" {
  description = "Number of VMs to create (between 2 and 100)"
  type        = number
  default     = 3
  validation {
    condition     = var.vm_count >= 2 && var.vm_count <= 100
    error_message = "VM count must be between 2 and 100."
  }
}

variable "vm_flavor" {
  description = "Flavor of the VMs"
  type        = string
  default     = "Standard_B2s"
}

variable "vm_image" {
  description = "Image of the VMs"
  type        = string
  default     = "22_04-lts"
}