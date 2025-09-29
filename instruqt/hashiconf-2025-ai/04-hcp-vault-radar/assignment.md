---
slug: hcp-vault-radar
id: uxs8586fpvwv
type: challenge
title: HCP Vault Radar
notes:
- type: text
  contents: |-
    <center>
    Clue #2
    <br><br>
    <hr>
    <br> <br>
    To find the next pair of digits, check underneath the stool.
    <br> <br><br>
    <hr>
    </center>
tabs:
- id: nx0bflepfyy0
  title: Terminal
  type: terminal
  hostname: tools
- id: fmi0aquxxuiw
  title: Code
  type: code
  hostname: tools
  path: /solutions
- id: cexxqwfgrztl
  title: HCP
  type: website
  url: https://vault-radar-portal.cloud.hashicorp.com/projects/40b67f0b-12b6-4184-9613-45cc9ef381f2/overview
  new_window: true
difficulty: ""
enhanced_loading: null
---
## Overview

Passwords, API keys, and other secrets in code are no longer secure when someone shares the code across teams, repositories are public, or when employees leave with copies of the code.

Vault Radar identifies and helps remove leaked secrets throughout the development workflow. It scans pull requests, alerts on commits to monitored repositories, and helps triage and mitigate secrets already committed.

The Security team scanned one of the repositories related to our Machine Learning pipeline, and discovered some concerning findings.

## Tasks

### Log into the HashiCorp Cloud Platform (HCP)
Type `creds` in the terminal to obtain login credentials, and then visit the `HCP` tab to get started.

### Analyze HCP Vault Radar
Discover the author (committer) and value (plaintext) of the secret that matches:
- `Status: Triaged`
- `Description: AWS secret key`

## Submission
Use the `Solutions` tab to store:
- the author (email) of the commit in a file named `/solutions/data.json`
- the secret value (plaintext) in a file named `/solutions/data.json`

Then click the `Check` button in the bottom right.
