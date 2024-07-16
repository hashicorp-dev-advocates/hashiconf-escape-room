terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.38.0"
    }

    terracurl = {
      source  = "devops-rob/terracurl"
      version = "1.2.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.93.0"
    }
  }
}

provider "aws" {
  # AWS credentials set up using environment variables
  region = var.aws_region
  default_tags {
    tags = {
      repository = "hashiconf-escape-room"
      purpose    = "nomad-infrastructure"
    }
  }
}

provider "terracurl" {}

provider "hcp" {
  project_id = var.hcp_project_id
}