terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      repository = "hashiconf-escape-room"
      purpose    = "nomad-applications"
    }
  }
}

provider "nomad" {
  address   = data.terraform_remote_state.nomad.outputs.nomad_ui
  secret_id = data.terraform_remote_state.nomad.outputs.nomad_management_token
}