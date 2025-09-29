---
slug: nomad
id: vo3wrxwm8swr
type: challenge
title: Nomad
tabs:
- id: kqcrfstrevun
  title: Terminal
  type: terminal
  hostname: tools
  workdir: /root/nomad_config
- id: xxabyx48qqp7
  title: Code
  type: code
  hostname: tools
  path: /root/nomad_config/
difficulty: ""
enhanced_loading: null
---
## Overview

HashiCorp Nomad is used to deploy and manage our Machine Learning pipelines which allows us to train the data model for our AI chatbot.

 Dynamic host volumes allow operators to create volumes on the host without the need to restart the Nomad client.

Your team has tasked you with  creating a volume named `models` within the `ml-pipeline` namespace for the job `model-sanitizer`.

## Tasks

### Configure a dynamic host volume
Edit the Nomad volume specification (`./volume.hcl`) as per the above specification in the editor.

### Create the dynamic host volume
Using the Nomad CLI, create the dynamic host volume from the Nomad volume specification
```shell
nomad volume create ./volume.hcl
```

## Submission
Click the `Check` button in the bottom right once the Nomad job has been deployed.