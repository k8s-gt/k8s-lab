# Terraform

## Remember, remember 🎶

### Create SSH Key

```bash
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

### All set!

Now you can use any of the providers within `terraform/` directory.

```shell
$ tree -d terraform
terraform
├── digitalocean
├── gcp
└── scripts
```

**NOTE:** The `terraform/scripts` does not represent a cloud provider.
