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

provider "aws" {
  # AWS credentials set up using environment variables
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

provider "hcp" {
  project_id = var.hcp_project_id
}