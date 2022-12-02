#!/bin/bash
##Fuentes:
#https://medium.com/analytics-vidhya/using-kops-to-setup-up-kubernetes-cluster-f83d83139f6a
#https://www.eksworkshop.com/

##Visita mi sitio: https://mencrypto.com

##Crear recursos en consola
#Rol AdministratorAccess: k8sworkshop-admin
#VM: AMI AWS | k8spoc | puertos 22 y 5000
#Storage S3: k8s-storage20210115

##Instalar paquetes de sistema operativo
sudo yum update -y
sudo yum -y install python3 pip3 jq bash_completion moreutils

#Instalar awscli
#sudo pip3 install --upgrade awscliv2 && hash -r
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install && rm -rf awscliv2.zip aws

##Conectarse y validar permisos de la VM
#rm -vf ${HOME}/.aws/credentials
#aws sts get-caller-identity --query Arn | grep k8sworkshop-admin -q && echo "IAM role valid" || echo "IAM role NOT valid"

aws sts get-caller-identity --query Arn | grep User1 -q && echo "IAM role valid" || echo "IAM role NOT valid"

##Generar y exportar clave ssh para conectarse a los nodos
ssh-keygen
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
#aws ec2 import-key-pair --key-name "eksworkshop" --public-key-material file://~/.ssh/id_rsa.pub --region=$AWS_REGION

aws ec2 import-key-pair --key-name "ec2-eks" --public-key-material file://~/.ssh/id_rsa.pub --region=$AWS_REGION

#Crear bucket de AWS
export storage=k8s-storage${RANDOM}
aws s3api create-bucket --bucket ${storage} --region ${AWS_REGION}

##Instalar kubectl
#sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.11/2020-09-18/bin/linux/amd64/kubectl
sudo curl --silent --location -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.7/2022-06-29/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
kubectl version

kubectl completion bash >>  ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion

##Instalar kops
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

##Crear Cluster
export KOPS_CLUSTER_NAME=poc.k8s.local
kops create cluster --yes --state=s3://${storage} --zones=us-east-1a --node-count=2 --node-size=t2.micro --master-size=t2.micro --name=${KOPS_CLUSTER_NAME}

#export KOPS_CLUSTER_NAME=kops.devopsinuse.com
#kops create cluster --yes --state=s3://${storage} --zones=us-east-1a --node-count=2 --node-size=t2.micro --master-size=t2.micro --master-count=1 --name=${KOPS_CLUSTER_NAME} --dns-zone=kops.devopsinuse.com --out=devopsinuse_terraform --target=terraform --ssh-public-key=~/.ssh/id_rsa.pub

#######
##Esperar a que se despliegue todos los nodos y pods
kubectl get all --all-namespaces

##Desplegar una aplicación
kubectl create deployment httpenv --image jpetazzo/httpenv
kubectl scale deployment httpenv --replicas=3
kubectl expose deployment httpenv --port 8888
kubectl get pods -o wide

##Tunel hacia el servicio en la máquina local
kubectl port-forward deployment/httpenv 5000:8888 &

#Revisar si tenemos respuesta del servicio
curl -s http://127.0.0.1:5000

##Conectarse a un nodo con la llave creada en pasos anteriores
kubectl get nodes -o wide
ssh -i ~/.ssh/id_rsa ubuntu@${IP}
sudo apt-get install jq -y

#Ciclo para revisar el curl extrayendo cual es la IP 
for i in $(seq 10); do curl -s http://127.0.0.1:5000 | jq ".HOSTNAME"; done

##Borrar Cluster
kops delete cluster --yes --state=s3://${storage} --name=${KOPS_CLUSTER_NAME}