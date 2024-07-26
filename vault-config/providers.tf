terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.93.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58.0"
    }
  }
}

provider "hcp" {
  project_id = var.hcp_project_id
}

resource "hcp_vault_cluster_admin_token" "vault" {
  cluster_id = data.terraform_remote_state.hcp.outputs.vault.cluster_id
}

provider "vault" {
  address = data.terraform_remote_state.hcp.outputs.vault.public_endpoint
  token = hcp_vault_cluster_admin_token.vault.token
}
