---
slug: hcp-packer
id: 5qsmzcto1ykl
type: challenge
title: HCP Packer
tabs:
- id: t3xwxzn0uurb
  title: Terminal
  type: terminal
  hostname: tools
  workdir: /
- id: mp5tcahdxsgj
  title: Solutions
  type: code
  hostname: tools
  path: /solutions
- id: fj01qhxgmmd8
  title: HCP
  type: website
  url: https://portal.cloud.hashicorp.com/services/packer/buckets?project_id=40b67f0b-12b6-4184-9613-45cc9ef381f2
  new_window: true
difficulty: ""
enhanced_loading: null
---
## Tasks
HashiCorp Packer was used to build multiple machine images, targeting `Ubuntu`, under the bucket `app-ubuntu` and channel `latest`.

The Packer template was configured to push metadata to HCP Packer, while storing the golden images on `AWS`.

Sometime later a critical CVE targeting Ubuntu was announced and your platform team revoked the single impacted artifact.

Using HCP Packer (browser):
- Find the Terraform data source that can be used to pull the latest AMI using HCP Packer
- Find the reason the specific artifact was revoked

## Submission
Use the `Solutions` tab to store:
- the CVE ID in a file named: `/solutions/data.json`
- the Terraform data source in a file named: `/solutions/data.tf`

## Credentials
To obtain HCP login credentials, type the following into the terminal:
```shell
creds
```
