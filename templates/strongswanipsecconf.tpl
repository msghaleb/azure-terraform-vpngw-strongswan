# ipsec.conf - strongSwan IPsec configuration file

# basic configuration

config setup
        # strictcrlpolicy=yes
        # uniqueids = no

# Add connections here.

# Sample VPN connections

#conn sample-self-signed
#      leftsubnet=10.1.0.0/16
#      leftcert=selfCert.der
#      leftsendcert=never
#      right=192.168.0.2
#      rightsubnet=10.2.0.0/16
#      rightcert=peerCert.der
#      auto=start

#conn sample-with-ca-cert
#      leftsubnet=10.1.0.0/16
#      leftcert=myCert.pem
#      right=192.168.0.2
#      rightsubnet=10.2.0.0/16
#      rightid="C=CH, O=Linux strongSwan CN=peer name"
#      auto=start

conn azure
  authby=secret
  type=tunnel
  leftsendcert=never
  left=${strongswanleft}
  leftsubnet=${strongswanleftsubnet}
  #leftnexthop=%defaultroute
  right=${strongswanright}
  rightsubnet=${strongswanrightsubnet}
  keyexchange=ikev2
  ikelifetime=10800s
  lifebytes=102400000
  keylife=57m
  keyingtries=1
  rekeymargin=3m
  #pfs=no
  compress=no
  auto=start