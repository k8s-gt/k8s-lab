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
cd kubernetes-examples
alias k=kubectl
k apply -f namespace.yaml 
k config set-context --current --namespace=example
k apply -f app1/
k port-forward service/my-service 8088:80
k scale deploy deployment-test --replicas=10
k get pods -o wide
```