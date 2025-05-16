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
  }
}

provider "hcp" {
  project_id = var.hcp_project_id
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      repository = "hashiconf-escape-room"
      purpose    = "hcp-infrastructure"
    }
  }
}