terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.93.0"
    }

    aws = {
      source = "hashicorp/aws"
      version = "5.60.0"
    }
  }
}

provider "hcp" {
  project_id = var.hcp_project_id
}

provider "consul" {
  address = data.terraform_remote_state.hcp.outputs.consul.public_endpoint
  token   = hcp_consul_cluster_root_token.root.secret_id
}

provider "aws" {
  region = var.aws_region
}

