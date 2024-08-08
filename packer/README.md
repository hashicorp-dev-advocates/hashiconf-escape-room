# packer images

These directories contain the Packer definitions to build images and push them
to HCP Packer.

They include:

* `app-ubuntu` - Nomad, Docker, Vault
* `base-linux` - base linux image
* `hashistack-ubuntu` - Nomad, Docker, Vault, Terraform, Consul

Refer to `.github/workspaces/packer.yaml` for the workflow
that pushes the images to AWS.

Note that the workflow uses dynamic credentials that federate GitHub
Actions workload identity with AWS.