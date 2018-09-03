# onprem.tf vars

variable "onprem_rg_name" {
  description = "Default resource group name that the onprem StrongSwan will be created in."
  default     = "onprem-rg"
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
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDb/x2BIWXTsORCyvh6YvNxP+T43Adux71rOV0Dep63aQvSm21+N8AMrIdSGSlseSdvXwl1CvPgTawkPHq4GeK0xNbljEaKLqHOUGr6ZMIcAhAhE/Y64oku8Vk1op5aG/IUnGZs4Qh17H07nMU/jCac1zJK3O2Bn2dMI9FLzq4gzdwwduKKA8Pt5NQqQJFACVAKGgBWGiSwgQuosa/JlfIY3wtm0kL4Vq9T8hLjIn34/g/mJAhK9P7NwF6Cz2wzphDqdD0y4TlqOq+S50KuEFUfIGcnKMXT2e8y2RBfMWI34HJiyMkdyjFDQRLlNJ/mOZ13uVI6ghCSLeFZp3a6zOxT moghaleb@europe@de-moghaleb2"
}

variable "azureonprem_vm_private_key" {
  description = "The private key path on the local PC running terraform used to provision your VMs"
  default     = "~/.ssh/id_rsa"
}
