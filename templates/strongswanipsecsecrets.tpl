# This file holds shared secrets or RSA private keys for authentication.

# RSA private key for this host, authenticating it to any other host
# which knows the public part.
# [STRONGSWAN LOCAL IP] [AZURE VNET GATEWAY PUBLIC IP] : PSK "[YOUR SHARED KEY]"
${strongswanlocalip} ${azurevpngwpublicip} : PSK "${strongswansharedkey}"