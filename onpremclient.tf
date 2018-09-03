variable "onpremprefix" {
  default = "onpremvm"
}

resource "azurerm_resource_group" "onpremrg" {
  name     = "${var.onpremprefix}-resources"
  location = "${var.onprem_rg_location}"
}

resource "azurerm_network_interface" "onpremnic" {
  name                = "${var.onpremprefix}-nic"
  location            = "${azurerm_resource_group.onpremrg.location}"
  resource_group_name = "${azurerm_resource_group.onpremrg.name}"

  ip_configuration {
    name                          = "${var.onpremprefix}ip"
    subnet_id                     = "${azurerm_subnet.azureonpremdefaultsubnet.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "onpremvm" {
  name                             = "${var.onpremprefix}-vm"
  location                         = "${azurerm_resource_group.onpremrg.location}"
  resource_group_name              = "${azurerm_resource_group.onpremrg.name}"
  network_interface_ids            = ["${azurerm_network_interface.onpremnic.id}"]
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
    name              = "${var.onpremprefix}osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.onpremprefix}server"
    admin_username = "testadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${var.azureonprem_vm_public_key}"
    }
  }

  tags {
    environment = "onprem_vm"
  }
}
