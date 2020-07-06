# Standalone Harbor install
----
## Use FQDN for install

```
IPorFQDN=$(hostname -f)
```

## Housekeeping
```
sudo apt update -y
sudo swapoff --all
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
sudo ufw disable
```

## Installing Latest Stable Docker Release and setting up docker daemon (if not already installed)
```
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries" : ["$IPorFQDN:443","$IPorFQDN:80","0.0.0.0/0"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo groupadd docker
MAINUSER=$(logname)
sudo usermod -aG docker $MAINUSER
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## Install Latest Stable Docker Compose Release
```
curl -s https://github.com/docker/compose/releases/latest/download
```
grep the Latest version and download the install - 1.25.5 in this example. 
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

## Install Latest Stable Harbor Release
```
curl -s https://github.com/goharbor/harbor/releases/latest/download
```
Grep the latest version of Harbor and download it. 1.10.2 in this example

```
curl -s https://api.github.com/repos/goharbor/harbor/releases/latest | grep browser_download_url | grep online | cut -d '"' -f 4 | wget -qi -
tar xvf harbor-online-installer-v1.10.2.tgz
cd harbor
sed -i "s/reg.mydomain.com/$IPorFQDN/g" harbor.yml
```

## Edit the install.sh file with changes.
* Comment out the http section
* Modify the admin password
* Update the https cert details.

```yaml
# Configuration file of Harbor

# The IP address or hostname to access admin UI and registry service.
# DO NOT use localhost or 127.0.0.1, because Harbor needs to be accessed by external clients.
hostname: harbor.navlab.io

# http related config
#http:
  # port for http, default is 80. If https enabled, this port will redirect to https port
#  port: 80

# https related config
https:
  # https port for harbor, default is 443
  port: 443
  # The path of cert and key files for nginx
  certificate: /home/nverma/harbor/publickey.pem
  private_key: /home/nverma/harbor/privkey.pem

# Uncomment external_url if you want to enable external proxy
# And when it enabled the hostname will no longer used
# external_url: https://bastion0.navlab.io:8433

# The initial password of Harbor admin
# It only works in first time to install harbor
# Remember Change the admin password from UI after launching Harbor.
harbor_admin_password: Passw0rd!
...
```
## Install with Clair/Notery and ChartMuseum 
```
sudo ./install.sh --with-clair --with-trivy --with-chartmuseum --with-notery
```
