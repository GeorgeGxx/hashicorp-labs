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
sudo snap install kubectl --classic &&
sudo wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -O /usr/local/bin/minikube &&
sudo chmod +x /usr/local/bin/minikube &&
sudo apt-get update -y &&
sudo apt-get install -y bash-completion &&
echo 'source <(kubectl completion bash)' >>~/.bashrc &&
sudo apt install -y maven &&
sudo snap install helm --classic &&
sudo usermod -aG docker azureuser && sudo usermod -aG docker ${USER} && newgrp docker &&
sudo minikube start
# &&
# minikube addons enable metrics-server && minikube addons enable ingress &&
# sudo mkdir repos && cd repos/ && sudo git clone -b master https://github.com/GeorgeGxx/springboot-micro-docker.git && cd springboot-micro-docker/docker-compose/ && sudo docker compose up -d