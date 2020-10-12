# onprem.tf vars

variable "onprem_rg_name" {
  description = "Default resource group name that the onprem StrongSwan will be created in."
  default     = "moga-onprem-rg"
}

variable "onprem_rg_location" {
  description = "The location/region where the core on prem network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "North Europe"
}

variable "azureonprem_strongswan_vm_size" {
  description = "The VM Size of the Strong Swan VM"
  default     = "Standard_D2s_v3"
}

variable "azureonpremvnet_address_space" {
  description = "The onprem vNET CIDR"
  default     = "10.3.0.0/16"
}

variable "azureonpremvnet_default_subnet" {
  description = "The onprem vNET Subnet CIDR"
  type = string
  default     = "10.3.0.0/24"
}

variable "azureonprem_strongswan_vm" {
  description = "The name of the Strong Swan VM"
  default     = "azureonpremstrongswan"
}

variable "azureonprem_vm_username" {
  description = "The username of the Strong Swan VM"
  default     = "strongswanuser"
}

variable "azureonprem_vm_public_key" {
  description = "The public key used to provision your VMs"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCed3Fl1O1kkk00BNDHfCHQ0ysimhIxFPIycD0wizbtlchjyfl3AJHyuHWWL004iI6b7dYiK+/ejRmxkCJP4n7h8cCJCC2gsUblnjLP1xxpRRuqhpwBbc8sDSqVVv1E2nvIUh+paMM2HGkIXqdFdk0mRpV5l0k6sz9Do8rKWU6tU+UJ4/Qrt1D1wqnouCxx5up2n4ZbpupHp4R71fDCEKvnt1fsq198M36pXrq8+z/Y34bmqJMa3x2wrVq60ht3XPsL1RwljPDCE5kxKAaKJ1IQppv8dyKANJbGw2/q82ODOpVB2dzMCzZYTsPo5gEc4vmfyv3/S3GN+zlPIQPdP7rx moghaleb@DE-MOGHALEB"
}

variable "azureonprem_vm_private_key" {
  description = "The private key path on the local PC running terraform used to provision your VMs"
  default     = "~/.ssh/id_rsa"
}
