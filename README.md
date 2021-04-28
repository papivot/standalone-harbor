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

## Installing Latest Stable Docker Release and setting up docker daemon (if not already installed) example on Ubuntu. 
```
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries" : ["$IPorFQDN:443","$IPorFQDN:80","0.0.0.0/0"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
  "dns":["dns_server"]
}
EOF
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo groupadd docker
MAINUSER=$(logname)
sudo usermod -aG docker $MAINUSER
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## Install Latest Stable Harbor Release v 2.2.1 in this example
```
wget https://github.com/goharbor/harbor/releases/download/v2.2.1/harbor-offline-installer-v2.2.1.tgz
tar xzvf harbor-offline-installer-v2.2.1.tgz
cd harbor
cp [your cert file] ./cert.pem 
cp [your key file] ./key/pem
```

## Modify the `install.yml` file. - Sample changes - 
```
---
hostname: harbor.navneetv.com
#http:
  #port: 80
https:
  port: 443
  certificate: /home/navneetv/workspace/harbor/harbor/cert.pem
  private_key: /home/navneetv/workspace/harbor/harbor/key.pem
harbor_admin_password: Password  
metric:
  enabled: true
  port: 9090
  path: /metrics
```

## Install with Clair/Notery and ChartMuseum 
```
sudo ./install.sh --with-trivy --with-chartmuseum --with-notary
```

## To stop,start and destroy Harbor 
```
cd ${directory containing the docker-compose.yml}
sudo docker-compose stop
sudo docker-compose start
# to complete destroy 
sudo docker-compose down -v  --remove-orphans
```
  
