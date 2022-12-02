#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
lsb-release \
software-properties-common &&
sudo apt-get install -y wget &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y &&
sudo apt install -y maven &&
sudo usermod -aG docker ubuntu && sudo usermod -aG docker $USER && newgrp docker  
# &&
# cd /home/ubuntu/ && sudo mkdir repos && cd repos/ && sudo git clone -b master https://github.com/GeorgeGxx/obs.git && cd obs/ && docker compose up -d