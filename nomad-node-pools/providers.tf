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