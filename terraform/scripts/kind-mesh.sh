#!/bin/bash

################################
#    _____      _
#   / ____|    | |
#  | (___   ___| |_ _   _ _ __
#   \___ \ / _ \ __| | | | '_ \
#   ____) |  __/ |_| |_| | |_) |
#  |_____/ \___|\__|\__,_| .__/
#                        | |
#                        |_|

## Configure docker repository and install packages
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin git jq firewalld

## Start services
sudo systemctl --now enable firewalld
sudo systemctl --now enable docker

## Install kind and kubectl
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
curl -Lo ./kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 ./kind /usr/bin/kind
sudo install -o root -g root -m 0755 ./kubectl /usr/bin/kubectl

## Clone project and create cluster
sudo git clone https://github.com/k8s-gt/k8s-lab.git /root/kind-mesh -b day-2

#########################
#   _  ___       _____
#  | |/ (_)     |  __ \
#  | ' / _ _ __ | |  | |
#  |  < | | '_ \| |  | |
#  | . \| | | | | |__| |
#  |_|\_\_|_| |_|_____/

# GCP Only - uncomment the next two lines
# export PUBLIC_IP=$(curl ifconfig.me)
# sudo sed -i "s/127.0.0.1/$PUBLIC_IP/g" /root/kind-mesh/kind/cluster.yaml

sudo kind create cluster --config /root/kind-mesh/kind/cluster.yaml

########################################
#   __  __      _        _ _      ____
#  |  \/  |    | |      | | |    |  _ \
#  | \  / | ___| |_ __ _| | |    | |_) |
#  | |\/| |/ _ \ __/ _` | | |    |  _ <
#  | |  | |  __/ || (_| | | |____| |_) |
#  |_|  |_|\___|\__\__,_|_|______|____/

## Implement MetalLB
sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
sudo kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
sudo kubectl apply -f /root/kind-mesh/metallb/configmap.yaml

## Wait for MetalLB to be ready
sleep 30

##########################
#   _____          _
#  |  __ \        | |
#  | |__) |__   __| |___
#  |  ___/ _ \ / _` / __|
#  | |  | (_) | (_| \__ \
#  |_|   \___/ \__,_|___/

cat << EOF > ~/day-2-manifest.yaml
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: http-echo
spec:
  containers:
  - name: foo-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=foo"
---
kind: Pod
apiVersion: v1
metadata:
  name: bar-app
  labels:
    app: http-echo
spec:
  containers:
  - name: bar-app
    image: hashicorp/http-echo:0.2.3
    args:
    - "-text=bar"
---
kind: Service
apiVersion: v1
metadata:
  name: echo-service
spec:
  type: LoadBalancer
  selector:
    app: http-echo
  ports:
  - name: http
    protocol: TCP
    port: 8081
    targetPort: 5678
EOF
sudo kubectl apply -f ~/day-2-manifest.yaml

###################################
#   _____             _
#  |  __ \           | |
#  | |__) |___  _   _| |_ ___  ___
#  |  _  // _ \| | | | __/ _ \/ __|
#  | | \ \ (_) | |_| | ||  __/\__ \
#  |_|  \_\___/ \__,_|\__\___||___/

## Expose echo-service LoadBalancer on 8081
export ECHO_LB_IP=$(sudo kubectl get service echo-service -o json | jq -r '.status.loadBalancer.ingress[] | .ip')
sudo firewall-cmd --add-port=8081/tcp --permanent
sudo firewall-cmd --add-forward-port=port=8081:proto=tcp:toport=8081:toaddr=$ECHO_LB_IP --permanent

## Enable traffic on both directions
export KIND_INTERFACE=$(ip -o -4 route show to 172.18.0.0/16 | awk '{print $3}')
sudo firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i eth0 -o $KIND_INTERFACE -j ACCEPT
sudo firewall-cmd --direct --permanent --add-rule ipv4 filter FORWARD 0 -i $KIND_INTERFACE -o eth0 -j ACCEPT
sudo firewall-cmd --reload
