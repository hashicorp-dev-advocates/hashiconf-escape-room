terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.106.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.65.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      repository = "hashiconf-escape-room"
      purpose    = "payments-infrastructure"
    }
  }
}

provider "hcp" {
  project_id = var.hcp_project_id
}

provider "tfe" {}