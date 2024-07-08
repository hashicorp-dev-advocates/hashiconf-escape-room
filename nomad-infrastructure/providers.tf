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
  }
}

provider "aws" {
  # AWS credentials set up using environment variables
  region = "us-east-1"
}

provider "terracurl" {}
