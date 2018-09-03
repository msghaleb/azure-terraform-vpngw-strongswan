# vpngw.tf vars

variable "vpn_rg_name" {
  description = "Default resource group name that the VPN GW will be created in."
  default     = "vpn-rg"
}

variable "vpn_rg_location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "North Europe"
}

variable "azurevpnvnet_address_space" {
  description = "The VPN vNET CIDR"
  default     = "10.2.0.0/16"
}

variable "azurevpnvnet_default_subnet" {
  description = "The VPN vNET Subnet CIDR"
  default     = "10.2.0.0/24"
}

variable "azurevpnvnet_gw_subnet" {
  description = "The VPN vNET Subnet CIDR"
  default     = "10.2.1.0/24"
}

variable "azurevpn_shared_key" {
  description = "The shared key used for the IPSec VPN between StrongSwan and Azure"
  default     = "4v3ry53cr371p53c5h4r3dk3yshgd65tsfgdvvx7654sakjs78ihd"
}
