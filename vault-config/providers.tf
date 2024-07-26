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
