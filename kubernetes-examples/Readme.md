# Kubernetes 101

## Example container.
```bash
docker pull elmerreal98/demohelm101-kcd
docker run -p 85:5000 --env-file example.env elmerreal98/demohelm101-kcd
```

# Colors
- ![#f03c15](https://via.placeholder.com/15/f03c15/f03c15.png) `#f03c15`
- ![#c5f015](https://via.placeholder.com/15/c5f015/c5f015.png) `#c5f015`
- ![#1589F0](https://via.placeholder.com/15/1589F0/1589F0.png) `#1589F0`

## Kubernetes commands
```bash
git clone https://github.com/k8s-gt/k8s-lab.git
cd k8s-lab
git checkout kubernetes

cd kubernetes-examples
alias k=kubectl
k apply -f namespace.yaml 
k config set-context --current --namespace=example
k apply -f app1/
#k port-forward service/my-service 8088:80
#k scale deploy deployment-test --replicas=3
watch kubectl get pods -o wide

## Expose Py on 8088
export EXAMPLE_LB_IP=$(sudo kubectl get service my-service-example -o json | jq -r '.status.loadBalancer.ingress[] | .ip')
sudo firewall-cmd --add-port=8088/tcp --permanent   
sudo firewall-cmd --add-forward-port=port=8088:proto=tcp:toport=80:toaddr=$EXAMPLE_LB_IP --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-all


k config set-context --current --namespace=default

```