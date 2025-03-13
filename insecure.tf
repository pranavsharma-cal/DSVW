provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "insecure_rg" {
  name     = "insecure-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "insecure_vnet" {
  name                = "insecure-vnet"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "insecure_subnet" {
  name                 = "insecure-subnet"
  resource_group_name  = azurerm_resource_group.insecure_rg.name
  virtual_network_name = azurerm_virtual_network.insecure_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "insecure_ip" {
  name                = "insecure-public-ip"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "insecure_nic" {
  name                = "insecure-nic"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name

  ip_configuration {
    name                          = "insecure-ip-config"
    subnet_id                     = azurerm_subnet.insecure_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.insecure_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "insecure_vm" {
  name                  = "insecure-vm"
  resource_group_name   = azurerm_resource_group.insecure_rg.name
  location              = azurerm_resource_group.insecure_rg.location
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "SuperInsecurePassword123!"  # Hardcoded password (Bad Practice)
  disable_password_authentication = false  # Allows password-based SSH login (Bad Practice)

  network_interface_ids = [
    azurerm_network_interface.insecure_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
