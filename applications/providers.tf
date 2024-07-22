terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.94.0"
    }
  }
}

provider "hcp" {
  project_id = var.hcp_project_id
}