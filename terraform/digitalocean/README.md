# Digital Ocean

Terraform is a tool for building, configuring, and deploying infrastructure.

This configuration creates a DigitalOcean droplet with a Kubernetes cluster and a MetalLB mesh.

## Setting up

### Generate DigitalOcean Personal Access Token

Create a new access token for the DigitalOcean API: <https://docs.digitalocean.com/reference/api/create-personal-access-token/>

### Create SSH Key

```bash
# Assuming you are at the repository root directory
$ cd terraform
$ ssh-keygen -t ed25519 -C "kind-mesh@digitalocean.com" -q -N '' -f ssh-key
$ ls
ssh-key      ssh-key.pub
```

### Start terraform env (container) and ssh agent

```shell
$ docker run -it --rm -v $(pwd):/kind-mesh -w /kind-mesh --entrypoint sh hashicorp/terraform
$ terraform version
Terraform v1.3.1
on linux_amd64
$ cd terraform
$ eval $(ssh-agent)
$ ssh-add ssh-key
```

### Export Digital Ocean PAT

```shell
$ pwd
/kind-mesh/terraform
$ cd digitalocean
$ export TF_VAR_digitalocean_token="dop_v1_...."
```

### Initialize Terraform

```shell
$ terraform init
... a verbose log output ...
$ terraform plan
... READ YO PLAN PPL!!1!! ...
```

## Fire it up 🔥

By running `terraform apply` it will:

* Create ssh key
* Create a droplet (AKA virtual machine)
* Install docker
* Install firewalld
* Install kind
* Install kubectl
* Create a Kubernetes-in-Docker cluster
* Install metallb
* Create a metallb configmap
* Run sample pods within in the cluster

## Resources

### DigitalOcean sizes

Check sizes.json for more info.

```shell
curl -X GET \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TF_VAR_digitalocean_token" \
  "https://api.digitalocean.com/v2/sizes" | jq . | less
```

## Always clean up when you finish 💸💸💸!

```shell
$ terraform destroy
[ terraform output + confirmation prompt]
```
