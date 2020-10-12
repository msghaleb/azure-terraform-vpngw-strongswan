![Alt text](img/visio_diagram.jpg?raw=true "Overview Diagram")
# azure-terraform-vpngw-strongswan
Terraform Repo to build Azure VPN Gateway, and connect it with StrongSwan simulating an on prem VPN gateway.

The Repo will build 4 Resource Groups:

1 - vpn-rg
This resource group will host the Azure VPN Gateway

2 - vpnvm-resrouces
This resource group is for a testing server behind the Azure VPN Gateway, initially the server will be implemented in the same vNET.

3 - onprem-rg
This resource group will host the StrongSwan server

4 - onpremvm-resources
This one will have initially a server to simulate a client behind the StrongSwan server, again will be in the same vNET as the StrongSwan server itself.

## How to use
- Install Terraform
- Install Azure CLI
- Clone the repo
- From the command promt run:
`az login`
- I recommend setting Terrafom to use a specific subscription to avoid surprises:
`az account set -s "subscriptionID"`
- Add your public key to the value of the variable `azureonprem_vm_public_key` in the `onprem.vars.tf` file
- Add your private key path to the value of the variable `azureonprem_vm_private_key`in the `onprem.vars.tf` file

> The public key is needed to provision all linux servers, the private key is needed for Terraform to initially install and configure StrongSwan.

- Run `terraform plan` to see what will happen and then `terraform apply`
- Reboot the StrongSwan server ```sudo reboot now```
- Login to the StrongSwan server and make sure the connection is up ```sudo ipsec status```

> Keey in mind, the username for the StrongSwan is ```strongswanuser``` however the username for the client servers is ```testadmin```

- login to one of the clients (you will need to copy the private Key used above) from the StrongSwan server (no public ip), and ping the other one.

> I recommend running it once before changing too much

For bugs open an issue and for recomendations fork and open a pull request.

Best of Luck

MoGa
