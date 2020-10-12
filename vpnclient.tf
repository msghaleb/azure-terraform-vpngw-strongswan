variable "vpnprefix" {
  default = "vpnvm"
}

resource "azurerm_resource_group" "vpnrg" {
  name     = "${var.vpnprefix}-resources"
  location = var.vpn_rg_location
}

resource "azurerm_network_interface" "vpnnic" {
  name                = "${var.vpnprefix}-nic"
  location            = azurerm_resource_group.vpnrg.location
  resource_group_name = azurerm_resource_group.vpnrg.name

  ip_configuration {
    name                          = "${var.vpnprefix}ip"
    subnet_id                     = azurerm_subnet.azurevpndefaultsubnet.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "vpnvm" {
  name                             = "${var.vpnprefix}-vm"
  location                         = azurerm_resource_group.vpnrg.location
  resource_group_name              = azurerm_resource_group.vpnrg.name
  network_interface_ids            = [azurerm_network_interface.vpnnic.id]
  vm_size                          = "Standard_D2s_v3"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vpnprefix}osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.vpnprefix}server"
    admin_username = "testadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/testadmin/.ssh/authorized_keys"
      key_data = var.azureonprem_vm_public_key
    }
  }

  tags = {
    environment = "onprem_vm"
  }
}
