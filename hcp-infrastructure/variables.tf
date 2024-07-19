variable "hcp_project_id" {
  type        = string
  description = "HCP project ID"
}

variable "repository" {
  type        = string
  description = "Repository with resources"
  default     = "hashiconf-escape-room"
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
    tier = "Standard"
  }
}

variable "github_user" {
  type        = string
  description = "GitHub user or organization for HCP Terraform GitHub app. Used to create no-code Terraform module for Waypoint"
}

variable "tf_github_app_installation_id" {
  type        = string
  description = "App installation ID for HCP Terraform GitHub app. Used to create no-code Terraform module for Waypoint. Get ID from https://app.terraform.io/app/settings/tokens"
}

variable "tf_module_repositories" {
  type        = set(string)
  description = "List of GitHub repositories with Terraform modules"
  default     = ["terraform-nomad-app"]
}