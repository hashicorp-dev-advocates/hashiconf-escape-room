terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.94.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.57.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.3.0"
    }
  }
}

provider "tfe" {}

provider "hcp" {
  project_id = var.hcp_project_id
}

data "terraform_remote_state" "nomad" {
  backend = "remote"

  config = {
    organization = var.hcp_terraform_organization
    workspaces = {
      name = "nomad-infrastructure"
    }
  }
}

provider "nomad" {
  address   = data.terraform_remote_state.nomad.outputs.nomad_ui
  secret_id = data.terraform_remote_state.nomad.outputs.nomad_management_token
}