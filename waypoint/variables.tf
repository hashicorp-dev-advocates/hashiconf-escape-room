variable "hcp_project_id" {
  type        = string
  description = "HCP project ID"
}

variable "hcp_terraform_project" {
  type        = string
  description = "Name of HCP Terraform project"
  default     = "hashiconf-escape-room"
}

variable "hcp_terraform_organization" {
  type        = string
  description = "Name of HCP Terraform organization"
  default     = "hashicorp-team-da-beta"
}