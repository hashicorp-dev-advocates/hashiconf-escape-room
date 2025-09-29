---
slug: hcp-terraform
id: mu8yaloyumcx
type: challenge
title: HCP Terraform
notes:
- type: text
  contents: |-
    <center>
    Clue #1
    <br><br>
    <hr>
    <br> <br>
    For the first two digts, find the page from HashiConf 2017 inside the HashiConf photo album.
    <br> <br><br>
    <hr>
    </center>
tabs:
- id: jyjlok94lzd0
  title: Terminal
  type: terminal
  hostname: tools
  workdir: /
- id: k8wf2y497hr1
  title: Code
  type: code
  hostname: tools
  path: /solutions
- id: tdgsyyussaxz
  title: HCP Terraform
  type: website
  url: https://app.terraform.io/app/hashicorp-team-da-beta/workspaces/payments-infrastructure
  new_window: true
difficulty: ""
enhanced_loading: null
---
## Tasks
Your team is now leveraging a Terraform data source to pull the latest artifact from HCP Packer for their `payments-infrastructure`. As seen in the prior step, your platform/security teams can revoke specific artifacts when vulnerabilities arise. HCP Packer has an HCP Terraform run task integration, which validates that the artifacts in your Terraform configuration have not been revoked for being insecure or outdated.

Auditors are requesting the IP address of the `payments-infrastructure`  deployed by a specific commit hash (`a5cf498`) which used the vulnerable image.

Using HCP Terraform (browser):
- View the run that was triggered by the commit hash  `a5cf498`
- Determine the `payments_vm_ip_address` from the outputs of the run

## Submission
Use the `Solutions` tab to store:
- the `payments_vm_ip_address` in a file named: `/solutions/data.json`

## Credentials
To obtain HCP login credentials, type the following into the terminal:
```shell
creds
```
