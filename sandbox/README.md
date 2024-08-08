# sandbox image

This creates a container image for the Instruqt track to use
as its sandbox host.

The image contains:

1. Vault
1. Boundary
1. Terraform
1. Consul
1. Nomad

Refer to `.github/workspaces/docker.yaml` for the workflow
that pushes the image to
[GitHub packages](https://github.com/hashicorp-dev-advocates/hashiconf-escape-room/pkgs/container/hashiconf-escape-room).