---
slug: hcp-vault
id: radj8hjo0gfn
type: challenge
title: HCP Vault
notes:
- type: text
  contents: |-
    <center>
    Clue #1
    <br><br>
    <hr>
    <br> <br>
    To find the first two digits, check underneath the rubber duck.
    <br> <br><br>
    <hr>
    </center>
tabs:
- id: m3yuein0sx07
  title: Vault CLI
  type: terminal
  hostname: tools
- id: yhkxeruqxdar
  title: Code
  type: code
  hostname: tools
  path: /solutions
- id: zucslye999sx
  title: OpenWeb UI
  type: website
  url: http://hashiconf-escape-room-open-webui-2031538392.us-west-2.elb.amazonaws.com/?temporary-chat=true
  new_window: true
difficulty: ""
enhanced_loading: null
---
## Overview

Retrieval-augmented generation (RAG) is a technique that enables large language models (LLMs) to retrieve and incorporate new information.

Before training the model, HCP Vault was used to tokenize the credit card numbers and billing addresses within our dataset.

This allows us to query the chatbot without the risk of leaking sensitive data. If required, users with proper permissions can use the token and obtain the original data from HCP Vault.

## Tasks

### Log into OpenWeb UI
Type `creds` in the terminal to obtain login credentials, and then visit the `OpenWeb UI` tab to get started.

### Query the Chatbot
Find the tokenized billing street address of `Derek Haney`.

> What information do you have on \<NAME>?

### Decode the tokenized data
Use HCP Vault to decode the tokenized billing street address of `Derek Haney`.

```shell
vault write payments/transform/decode/payments \
  transformation=address \
  value=<token>
```

## Submission
Use the `Solutions` tab to store:
- the decoded billing address in a file named `/solutions/data.json`
	- Update the address field with the decoded billing address retrieved from the chatbot

Then click the `Check` button in the bottom right.