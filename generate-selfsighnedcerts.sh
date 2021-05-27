#!/bin/bash

fqdn=apps.navneetv.com
ipaddress=10.100.1.1
#fqdn=apps.navlab.io

# Generate a CA Cert Private Key"
sudo openssl genrsa -out ca.key 4096

# Generate a CA Cert Certificate"
sudo openssl req -x509 -new -nodes -sha512 -days 3650 -subj "/C=US/ST=VA/L=Ashburn/O=SE/OU=Personal/CN=${fqdn}" -key ca.key -out ca.crt

# Generate a Server Certificate Private Key"
sudo openssl genrsa -out ${fqdn}.key 4096

# Generate a Server Certificate Signing Request"
sudo openssl req -sha512 -new -subj "/C=US/ST=VA/L=Ashburn/O=SE/OU=Personal/CN=${fqdn}" -key ${fqdn}.key -out ${fqdn}.csr

# Generate a x509 v3 extension file"
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=${fqdn}
DNS.2=*.${fqdn}
IP.1=${ipaddress}
EOF

# Use the x509 v3 extension file to gerneate a cert for the Harbor host"
sudo openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA ca.crt -CAkey ca.key -CAcreateserial -in ${fqdn}.csr -out ${fqdn}.cert
