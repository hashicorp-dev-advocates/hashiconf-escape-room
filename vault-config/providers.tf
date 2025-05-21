terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.106.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.8.0"
    }
  }
}

provider "hcp" {
  project_id = var.hcp_project_id
}

provider "vault" {
  address = data.terraform_remote_state.hcp.outputs.vault.public_endpoint
  token   = hcp_vault_cluster_admin_token.vault.token
}
