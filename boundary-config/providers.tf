terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.106.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98.0"
    }

    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.2.0"
    }
  }
}

provider "hcp" {
  project_id = var.hcp_project_id
}

provider "boundary" {
  addr                   = data.terraform_remote_state.hcp.outputs.boundary.public_endpoint
  auth_method_login_name = data.terraform_remote_state.hcp.outputs.boundary.username
  auth_method_password   = data.terraform_remote_state.hcp.outputs.boundary_password
  scope_id               = "global"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      repository = "hashiconf-escape-room"
      purpose    = "boundary-config"
    }
  }
}

provider "aws" {
  alias  = "boundary"
  region = var.aws_region
}

