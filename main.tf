provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "${var.name}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "test" {
  name                = "${var.name}-vnet"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "${var.name}-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.10.1.0/24"]
}
resource "azurerm_network_interface" "test" {
  name                = "${var.name}-nic"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "${var.name}-nic-ip-config"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id

  }
}
resource "azurerm_public_ip" "test" {
  name                = "${var.name}-public-ip"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"
  tags = {
    environment = "dev"
  }
}
resource "azurerm_network_security_group" "test" {
  name                = "${var.name}-security-group"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_network_security_rule" "test" {
  name                        = "${var.name}-security-rule"
  priority                    = 1100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = var.name
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  network_interface_ids           = [azurerm_network_interface.test.id]
  size                            = "Standard_B1s"
  computer_name                   = "ds2022"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false




  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "${var.name}-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

}