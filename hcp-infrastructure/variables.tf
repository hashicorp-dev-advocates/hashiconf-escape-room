variable "hcp_project_id" {
  type        = string
  description = "HCP project ID"
}

variable "repositories" {
  type        = list(string)
  description = "Repository with resources"
  default     = ["hashiconf-escape-room", "hashiconf-leaderboard"]
}

variable "name" {
  type        = string
  description = "Name of HCP resources"
  default     = "hashiconf-escape-room"
}

variable "hcp_cidr_block" {
  type        = string
  default     = "172.25.0.0/16"
  description = "CIDR block of the HashiCorp Virtual Network"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "hcp_terraform_aws_audience" {
  type        = string
  default     = "aws.workload.identity"
  description = "The audience value to use in run identity tokens"
}

variable "hcp_terraform_organization" {
  type    = string
  default = "hashicorp-team-da-beta"
}

variable "hcp_vault" {
  type = object({
    public_endpoint = bool
    tier            = string
  })
  description = "Attributes for HCP Vault cluster"
  default = {
    public_endpoint = true
    tier            = "dev"
  }
}

variable "hcp_consul" {
  type = object({
    public_endpoint = bool
    tier            = string
  })
  description = "Attributes for HCP Consul cluster"
  default = {
    public_endpoint = true
    tier            = "development"
  }
}

variable "hcp_boundary" {
  type = object({
    tier = string
  })
  description = "Attributes for HCP Boundary cluster"
  default = {
    tier = "Plus"
  }
}

variable "github_user" {
  type        = string
  description = "GitHub user or organization for repository"
  default     = "hashicorp-dev-advocates"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name for session recordings"
  default     = "hashiconf-recordings"
}

variable "aws_iam_user" {
  type        = string
  description = "AWS IAM user for Boundary session recordings"
  sensitive   = true
}