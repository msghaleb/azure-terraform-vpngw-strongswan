# Create the Azure on prem resource group
resource "azurerm_resource_group" "azureonpremrg" {
  name     = "${var.onprem_rg_name}"
  location = "${var.onprem_rg_location}"
}

# Create a Public IP for our VPN Gateway
resource "azurerm_public_ip" "azureonprempubip" {
  name                         = "azureonprempubip"
  location                     = "${azurerm_resource_group.azureonpremrg.location}"
  resource_group_name          = "${azurerm_resource_group.azureonpremrg.name}"
  public_ip_address_allocation = "Static"
}

# Create a Network security Group for our StrongSwan Server
resource "azurerm_network_security_group" "azureonpremnsg" {
  name                = "azureonpremnsg"
  location            = "${azurerm_resource_group.azureonpremrg.location}"
  resource_group_name = "${azurerm_resource_group.azureonpremrg.name}"

  security_rule {
    name                       = "Allow_ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_500"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "500"
    source_address_prefix      = "${data.azurerm_public_ip.azurevpnpubip.ip_address}"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_4500"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4500"
    source_address_prefix      = "${data.azurerm_public_ip.azurevpnpubip.ip_address}"
    destination_address_prefix = "*"
  }

  depends_on = [
    "data.azurerm_public_ip.azurevpnpubip",
  ]
}

# Create a virtual network within the on prem resource group
resource "azurerm_virtual_network" "azureonpremvnet" {
  name                = "azureonpremvnet"
  address_space       = ["${var.azureonpremvnet_address_space}"]
  location            = "${azurerm_resource_group.azureonpremrg.location}"
  resource_group_name = "${azurerm_resource_group.azureonpremrg.name}"
}

# Create a user defined route to forward traffic to the StrongSwan - no routes will be created here yet
resource "azurerm_route_table" "azureonpremudrtable" {
  name                          = "azureonpremudrtable"
  location                      = "${azurerm_resource_group.azureonpremrg.location}"
  resource_group_name           = "${azurerm_resource_group.azureonpremrg.name}"
  disable_bgp_route_propagation = true
}

# Create the default subnet 
resource "azurerm_subnet" "azureonpremdefaultsubnet" {
  name                      = "default"
  resource_group_name       = "${azurerm_resource_group.azureonpremrg.name}"
  virtual_network_name      = "${azurerm_virtual_network.azureonpremvnet.name}"
  address_prefix            = "${var.azureonpremvnet_default_subnet}"
  network_security_group_id = "${azurerm_network_security_group.azureonpremnsg.id}"
  route_table_id            = "${azurerm_route_table.azureonpremudrtable.id}"

  depends_on = [
    "azurerm_route_table.azureonpremudrtable",
  ]
}

# Now we are ready to create the route
resource "azurerm_route" "azureonpremudr" {
  name                   = "azureonpremudrtable"
  resource_group_name    = "${azurerm_resource_group.azureonpremrg.name}"
  route_table_name       = "${azurerm_route_table.azureonpremudrtable.name}"
  address_prefix         = "${var.azurevpnvnet_default_subnet}"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = "${azurerm_network_interface.azureonpremstrongswanvmnic.private_ip_address}"
}

# Create the Network Interface for the StrongSwan VM
resource "azurerm_network_interface" "azureonpremstrongswanvmnic" {
  name                      = "${var.azureonprem_strongswan_vm}-nic"
  location                  = "${azurerm_resource_group.azureonpremrg.location}"
  resource_group_name       = "${azurerm_resource_group.azureonpremrg.name}"
  network_security_group_id = "${azurerm_network_security_group.azureonpremnsg.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "azureonpremstrongswanip"
    subnet_id                     = "${azurerm_subnet.azureonpremdefaultsubnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.azureonprempubip.id}"
  }
}

# Create the Strong Swan VM
resource "azurerm_virtual_machine" "azureonpremstrongswanvm" {
  name                             = "${var.azureonprem_strongswan_vm}"
  location                         = "${azurerm_resource_group.azureonpremrg.location}"
  resource_group_name              = "${azurerm_resource_group.azureonpremrg.name}"
  network_interface_ids            = ["${azurerm_network_interface.azureonpremstrongswanvmnic.id}"]
  vm_size                          = "${var.azureonprem_strongswan_vm_size}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "azureonpremosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.azureonprem_strongswan_vm}"
    admin_username = "${var.azureonprem_vm_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.azureonprem_vm_username}/.ssh/authorized_keys"
      key_data = "${var.azureonprem_vm_public_key}"
    }
  }

  connection {
    type        = "ssh"
    user        = "${var.azureonprem_vm_username}"
    private_key = "${file("${var.azureonprem_vm_private_key}")}"
    timeout = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "sudo apt-get install -y strongswan",
      "sudo apt-get install -y dos2unix",
      "touch /tmp/ipsec.conf",
      "touch /tmp/ipsec.secrets",
      "touch /tmp/sysctl.conf",
      "sudo systemctl restart networking.service &",
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.strongswanipsecconf.rendered}"
    destination = "/tmp/ipsec.conf"
  }

  provisioner "file" {
    content     = "${data.template_file.strongswanipsecsecrets.rendered}"
    destination = "/tmp/ipsec.secrets"
  }

  provisioner "file" {
    source      = "templates/strongswansysctlconf.tpl"
    destination = "/tmp/sysctl.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dos2unix /tmp/ipsec.conf /tmp/ipsec.secrets /tmp/sysctl.conf",
      "sudo apt-get remove -y dos2unix",
      "sudo mv /etc/ipsec.conf /etc/ipsec.conf.bkp",
      "sudo mv /etc/ipsec.secrets /etc/ipsec.secrets.bkp",
      "sudo mv /etc/sysctl.conf /etc/sysctl.conf",
      "sudo mv /tmp/ipsec.conf /etc/ipsec.conf",
      "sudo mv /tmp/ipsec.secrets /etc/ipsec.secrets",
      "sudo mv /tmp/sysctl.conf /etc/sysctl.conf",
      "sudo systemctl restart strongswan.service &",
    ]
  }

  depends_on = ["azurerm_network_interface.azureonpremstrongswanvmnic"]
}
