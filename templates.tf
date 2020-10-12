# Template for initial configuration of StrongSwan
data "template_file" "strongswanipsecconf" {
  template = "${file("templates/strongswanipsecconf.tpl")}"

  vars = {
    strongswanleft        = "${azurerm_network_interface.azureonpremstrongswanvmnic.private_ip_address}"
    strongswanleftsubnet  = "${var.azureonpremvnet_default_subnet}"
    strongswanright       = "${data.azurerm_public_ip.azurevpnpubip.ip_address}"
    strongswanrightsubnet = "${var.azurevpnvnet_default_subnet}"
  }
  depends_on = [
    data.azurerm_public_ip.azurevpnpubip,
  ]
}

# Template for the shared key configuration of StrongSwan VPN
data "template_file" "strongswanipsecsecrets" {
  template = "${file("templates/strongswanipsecsecrets.tpl")}"

  vars = {
    strongswanlocalip   = "${azurerm_network_interface.azureonpremstrongswanvmnic.private_ip_address}"
    azurevpngwpublicip  = "${data.azurerm_public_ip.azurevpnpubip.ip_address}"
    strongswansharedkey = "${var.azurevpn_shared_key}"
  }
  depends_on = [
    data.azurerm_public_ip.azurevpnpubip,
  ]
}
