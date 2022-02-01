# Standalone Harbor install
----
## Use FQDN for install

```
IPorFQDN=$(hostname -f)
```

## Housekeeping
```console
sudo apt update -y
sudo swapoff --all
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
sudo ufw disable
```

## Installing Latest Stable Docker Release and setting up docker daemon (if not already installed) example on Ubuntu. 
```console
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose\n
sudo chmod +x /usr/local/bin/docker-compose
sudo groupadd docker
MAINUSER=$(logname)
sudo usermod -aG docker $MAINUSER
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl restart docker
```

## Install Latest Stable Harbor Release v 2.2.1 in this example
```console
wget https://github.com/goharbor/harbor/releases/download/v2.4.1/harbor-offline-installer-v2.4.1.tgz
tar xzvf harbor-offline-installer-v2.4.1.tgz
cd harbor
cp [your cert file] ./cert.pem 
cp [your key file] ./key/pem
```

## Modify the `install.yml` file. - Sample changes - 
```yaml
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
```console
sudo ./install.sh --with-trivy --with-chartmuseum --with-notary
```
## Hacks for air-gapped environment 

On a server with internet connections, download the trivy DB file and all the docker images that need to be dwonloaded
```console
wget https://github.com/aquasecurity/trivy-db/releases/latest/download/trivy-offline.db.tgz

docker login -u user_name your_public_registry_id
docker pull hello-world
docker save hello-world:latest > hello-world.latest.tar
=====
### Now copy these files to the Harbor server
```

On the server running Harbor 
```console
#### To upload container images downloaded earlier
#
docker login -u admin harbor.env1.lab.local
docker load --input hello-world.latest.tar
docker tag hello-world:latest harbor.env1.lab.local/library/hello-world:latest
docker push harbor.env1.lab.local/library/hello-world

#### To install /setup the Trivy DB
#
wget https://github.com/aquasecurity/trivy-db/releases/latest/download/trivy-offline.db.tgz
sudo mv trivy-offline.db.tgz /data/trivy-adapter/trivy/db
sudo tar xvf trivy-offline.db.tgz
sudo rm trivy-offline.db.tgz
sudo chown 10000:10000 -R /data/trivy-adapter/trivy/db
sudo chmod 700 /data/trivy-adapter/trivy/db
sudo chmod 644 /data/trivy-adapter/trivy/db/trivy.db
sudo chmod 644 /data/trivy-adapter/trivy/db/metadata.json
```

## To stop,start and destroy Harbor 
```console
cd ${directory containing the docker-compose.yml}
sudo docker-compose stop
sudo docker-compose start
# to complete destroy 
sudo docker-compose down -v  --remove-orphans
```
  
