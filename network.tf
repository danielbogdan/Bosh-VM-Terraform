resource "azurerm_virtual_network" "bosch-test-vnet" {
  name                = "bosch-test-vnet"
  address_space       = var.address_space
  location            = azurerm_resource_group.bosch-test.location
  resource_group_name = azurerm_resource_group.bosch-test.name
}


resource "azurerm_network_security_group" "bosch-test-nsg" {
  name                = "nsg-test-${local.env_name}-${local.env_project}"
  location            = azurerm_resource_group.bosch-test.location
  resource_group_name = azurerm_resource_group.bosch-test.name

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "bosch-test" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.bosch-test-iface[count.index].id
  network_security_group_id = azurerm_network_security_group.bosch-test-nsg.id
}

resource "azurerm_subnet" "bosch-test" {
  name                 = "bosch-test-subnet"
  resource_group_name  = azurerm_resource_group.bosch-test.name
  virtual_network_name = azurerm_virtual_network.bosch-test-vnet.name
  address_prefixes     = var.infra_subnet
}

resource "azurerm_network_interface" "bosch-test-iface" {
  count               = var.vm_count
  name                = "bosch-test-nic-${count.index}"
  location            = azurerm_resource_group.bosch-test.location
  resource_group_name = azurerm_resource_group.bosch-test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bosch-test.id
    private_ip_address_allocation = "Dynamic"
  }
}