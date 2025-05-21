# HashiConf 2025 Escape Rooms

This repository contains all setup and configuration code for the infrastructure required for the HashiConf 2025 Escape room challenge. This is a mono-repository with multiple Terraform workspaces for each domain area. For more information, please speak to Rosemary or Rob.

The Instruqt tracks have been exported and are located in the `instruqt/` directory.

## Technical details

All products use [HCP](https://portal.cloud.hashicorp.com/orgs/9bb8f131-ef42-41f7-af76-5c18ea485b27/projects/40b67f0b-12b6-4184-9613-45cc9ef381f2)
except Nomad. Nomad runs on AWS EC2 instances.

The clients and workers all run on AWS in `us-west-2`.

If any of the endpoints change, you will need to re-run workspaces in
[HCP Terraform](https://app.terraform.io/app/hashicorp-team-da-beta/workspaces?project=prj-xNaqDZgrzXfEWSuY).
The workspaces require the following order:

1. `hcp-infrastructure`
1. `nomad-infrastructure`
1. `nomad-node-pools`
1. `vault-config`
1. `boundary-config`

Other technicalities:

- HCP Terraform uses dynamic credentials for AWS. Review `hcp-infrastructure` for configuration.

- Images get pushed to HCP Packer with a GitHub Actions workflow.
  GitHub Actions also uses dynamic credentials, review `hcp-infrastructure` for configuration.

## Manual configuration

- Creation of AWS credentials for `hcp-infrastructure` to configure dynamic credentials
- Read-only user for escape room