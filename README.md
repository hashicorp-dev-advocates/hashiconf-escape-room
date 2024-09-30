# HashiConf 2024 Escape Rooms

This repository contains all setup and configuration code for the infrastructure required for the HashiConf 2024 Escape room challenge. This is a mono-repository with multiple Terraform workspaces for each domain area. For more information, please speak to Rosemary or Rob.

* Infrastructure lifecycle management (ILM) - puzzles use Waypoint, Terraform, Nomad, and Packer
* Security lifecycle management (SLM) - puzzles use Vault, Consul, and Boundary

## Important links

### Registration

- [Form](https://hashi.co/hashiconf24-escape-room)
- Scan badge.
- ILM/SLM sticker

### Instruqt tracks

These are the official puzzles for ILM/SLM:

- [ILM](https://play.instruqt.com/hashicorp-field-ops/tracks/hashiconf-2024-ilm)
- [SLM](https://play.instruqt.com/hashicorp-field-ops/tracks/hashiconf-2024-slm)

Version 2 of the tracks in case the puzzles are compromised:

- [ILM](https://play.instruqt.com/manage/hashicorp-field-ops/tracks/hashiconf-2024-ilm-v2)
- [SLM](https://play.instruqt.com/manage/hashicorp-field-ops/tracks/hashiconf-2024-slm-v2)

### Leaderboard

- [Frontend](https://hashi.co/hashiconf24-leaderboard)
- [Admin](https://hashi.co/hashiconf24-leaderboard-admin)

## Backup plans

- If Instruqt, HCP, or AWS goes down, switch to [backup slides](https://docs.google.com/presentation/d/1kikqISVF8vwCPVSfe20xnl65E9svFt8TvJ2EqQglyMQ/edit?usp=sharing) with clues and video playback
- If Nomad, Waypoint, Packer goes down, let staff outside know we are only running SLM.
- If HCP Vault, Boundary, or Consul goes down, let staff outside know we are only running ILM.

## Technical details

All products use [HCP](https://portal.cloud.hashicorp.com/orgs/9bb8f131-ef42-41f7-af76-5c18ea485b27/projects/40b67f0b-12b6-4184-9613-45cc9ef381f2)
except Nomad. Nomad runs on AWS EC2 instances.

The clients and workers all run on AWS in `us-east-2`.

If any of the endpoints change, you will need to re-run workspaces in
[HCP Terraform](https://app.terraform.io/app/hashicorp-team-da-beta/workspaces?project=prj-xNaqDZgrzXfEWSuY).
The workspaces require the following order:

1. `hcp-infrastructure`
1. `nomad-infrastructure`
1. `nomad-node-pools`
1. `clues`
1. `waypoint`
1. `applications`
1. `vault-config`
1. `consul-config`
1. `boundary-config`

Other technicalities:

- HCP Terraform uses dynamic credentials for AWS. Review `hcp-infrastructure` for configuration.

- Images get pushed to HCP Packer with a GitHub Actions workflow.
  GitHub Actions also uses dynamic credentials, review `hcp-infrastructure` for configuration.

- Secrets get synchronized from various resources to
  GitHub Actions using HCP Vault Secrets. Check out `hcp-infrastructure/hvs.tf`
  for a list of secrets. **NOTE: The sync is manually configured in HCP Vault Secrets!**

## Updating clues

In order for changes to propagate across tools, you need to change
clues in a few places.

A complete list of valid clues can be found at [`clues/README.md`](./clues/README.md).

### ILM

There are two places to update clues for infrastructure lifecycle management puzzles.

1. Waypoint and Nomad
   1. Go to `clues/`.
   1. Update `terraform.auto.tfvars`.
   1. Push.
   1. This will run the `clues` workspace in HCP Terraform.
   1. Run workspaces corresponding to each application.
1. Packer
   1. Go to `.github/workflows/packer`.
   1. Update the `HCP_PACKER_BUILD_DETAILS` for each job.

### SLM

TODO