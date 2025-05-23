terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.5.0"
    }
  }
}

provider "nomad" {
  address   = data.terraform_remote_state.nomad.outputs.nomad_ui
  secret_id = data.terraform_remote_state.nomad.outputs.nomad_management_token
}