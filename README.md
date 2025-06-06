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
- Creation of GitHub fine-grained token for `hcp-infrastructure` to write HCP credentials to GitHub Actions
  - Only needs access to GitHub Actions Secrets and Variables for `hashiconf-escape-room`
- Creation of GitHub fine-grained token for `open-webui-config` to write Open WebUI JWT token to GitHub Actions
  - Only needs access to GitHub Actions Secrets and Variables for `hashiconf-escape-room-data`

### AI puzzle

The HCP Terraform workspaces require the following order:
1. `nomad-applications`
1. `open-webui-config`

For the AI workflow, there is a separate repository at [hashiconf-escape-room-data](https://github.com/hashicorp-dev-advocates/hashiconf-escape-room-data)
that includes the data. It uses terracurl to create an `attendee` user and set up the knowledge base, although there are some problems with the workflow.
Due to limitations of providers, you must manually delete the knowledge base and remove everything from state.

Next, you need to import the models into Ollama.

1. Go to Nomad and click on the `ollama` job.
1. Under Actions, be sure to `pull-model` and `pull-embeddings`.

#### Technical gotchas

The AI portions are divided into two parts:
1. Ollama to run the models (Granite) - requires multiple GPUs for models to run properly
1. Open WebUI as an AI interface for chatting - no GPUs required

In order to access Open WebUI, we deploy a Nginx reverse proxy to access it.

Running Ollama + Granite requires multiple GPUs and VRAM because Granite's context length is 128K.
To ensure that we do not overload VRAM, we are using the `granite3.3:2b` model. EC2 instance sizing
based on [related documentation](https://www.ibm.com/docs/en/software-hub/5.1.x?topic=install-foundation-models#watsonxai-models__txt-extract).
If you overload VRAM, Ollama will fall back to CPU. The Ollama container has increased resource limits to account for fallback.

#### Manual configuration of Open WebUI

- Set up of admin account
  1. Go to Open WebUI.
  1. Sign up with the following:
     - Name: Admin
     - Email: `cd nomad-applications && terraform output open_webui_admin_username`
     - Password: `cd nomad-applications && terraform output open_webui_admin_password`
  1. Click "Create Admin Account".

- Export the API key for the Open WebUI API.
  1. Go to the user profile -> Settings.
  1. Go to Account.
  1. Show API keys.
  1. Generate an API key and paste it into the `open_webui_token` variable in HCP Terraform `open-webui-config` workspace

> Note: This does not use JWT tokens because they expire each time Open WebUI restarts.

- Fix Document settings.
  1. Go to Admin Panel -> Settings -> Documents.
  1. Under General, change the following:
     1. Chunk size: 2048
     1. Chunk overlap: 1024
  1. Under Retrieval, change the following:
     1. Top K: 15

- Attach knowledge base to HashiConf Escape Room Model
  1. Log in as admin user.
  1. Go to Workspaces -> Models
  1. Click on the pencil to edit the model.
  1. Make sure `credit-card-forms` is added to the Knowledge section and save changes.

- Turn off Arena Models (feature that compares models).
  1. Go to Admin Panel -> Settings -> Evaluations.
  1. Under General, disable Arena Models.

- Turn on Temporary Chat.
  1. Go to the `hashiconf-escape-room-data` repository. Get the email login and password for attendees from the HCP Terraform workspace (`terraform output -raw attendee_password`).
  1. Use the email and password to log into Open WebUI as a `HashiConf Escape Room Attendee`.
  1. Under the model name (`granite3.3:2b`), enable Temporary Chat.
  1. This ensures that we do not keep the chat history between escape room runs.

#### Troubleshooting

- Open WebUI returns a chat message with `SyntaxError: Unexpected token '<', "<html><h"... is not valid JSON`. Restart the nginx job in Nomad,
  this is likely because nginx did not properly refresh with a new backend endpoint.

- Open WebUI chat is running slow. This may be because Ollama is using too much VRAM on GPUs and is falling back to CPUs.
  - Restart the ollama job in Nomad. If that does not help...
  - Exec into the Nomad job and run `ollama ps` to check how much GPU the model is using.
  - Use Boundary to SSH into the LLM node and run `sudo nvidia-smi` to check GPU usage.

### Vulnerability patch management workflow

The HCP Terraform workspaces require the following order:
1. `payments-infrastructure`

## Expiration dates

| Description | Date |
| -------- | ------- |
| Shutdown AI workflow related instances  | October 1, 2025 |
| GitHub fine-grained tokens for HCP Terraform | December 6, 2025 |