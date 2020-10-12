# Create the Azure VPN GW resource group
resource "azurerm_resource_group" "azurevpnrg" {
  name     = var.vpn_rg_name
  location = var.vpn_rg_location
}

# Create a virtual network within the VPN GW resource group
resource "azurerm_virtual_network" "azurevpnvnet" {
  name                = "azurevpnvnet"
  address_space       = [var.azurevpnvnet_address_space]
  location            = azurerm_resource_group.azurevpnrg.location
  resource_group_name = azurerm_resource_group.azurevpnrg.name
}

# Create the default subnet 
resource "azurerm_subnet" "azurevpndefaultsubnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.azurevpnrg.name
  virtual_network_name = azurerm_virtual_network.azurevpnvnet.name
  address_prefixes     = [var.azurevpnvnet_default_subnet]
}

# Create the Gateway Subnet
resource "azurerm_subnet" "azurevpngwsubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.azurevpnrg.name
  virtual_network_name = azurerm_virtual_network.azurevpnvnet.name
  address_prefixes     = [var.azurevpnvnet_gw_subnet]
}

# Create a Public IP for our VPN Gateway
resource "azurerm_public_ip" "azurevpnpubip" {
  name                         = "azurevpnpubip"
  location                     = azurerm_resource_group.azurevpnrg.location
  resource_group_name          = azurerm_resource_group.azurevpnrg.name
  allocation_method            = "Dynamic"
}

# Create the Virtual Network Gateway - VPN
resource "azurerm_virtual_network_gateway" "azurevpngw" {
  name                = "azurevpngw"
  location            = azurerm_resource_group.azurevpnrg.location
  resource_group_name = azurerm_resource_group.azurevpnrg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.azurevpnpubip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.azurevpngwsubnet.id
  }

  depends_on = [
    azurerm_public_ip.azurevpnpubip,
    azurerm_subnet.azurevpngwsubnet,
  ]
}

# Get the Dynamic Public IP Address of the VPN Gateway
data "azurerm_public_ip" "azurevpnpubip" {
  name                = azurerm_public_ip.azurevpnpubip.name
  resource_group_name = azurerm_resource_group.azurevpnrg.name
  depends_on = [
    azurerm_virtual_network_gateway.azurevpngw
  ]
}

# Create a local Network Gateway, this respresents the on prem gateway
resource "azurerm_local_network_gateway" "azureonpremgw" {
  name                = "azureonpremgw"
  resource_group_name = azurerm_resource_group.azurevpnrg.name
  location            = azurerm_resource_group.azurevpnrg.location
  gateway_address     = azurerm_public_ip.azureonprempubip.ip_address
  address_space       = [var.azureonpremvnet_address_space]

  depends_on = [
    azurerm_virtual_network_gateway.azurevpngw,
    azurerm_public_ip.azureonprempubip,
  ]
}

# Create a VPN connection
resource "azurerm_virtual_network_gateway_connection" "azureonpremconnection" {
  name                = "azureonpremconnection"
  location            = azurerm_resource_group.azurevpnrg.location
  resource_group_name = azurerm_resource_group.azurevpnrg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.azurevpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.azureonpremgw.id

  shared_key = var.azurevpn_shared_key

  depends_on = [
    azurerm_local_network_gateway.azureonpremgw,
  ]
}
