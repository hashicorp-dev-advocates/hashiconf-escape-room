variable "hcp_project_id" {
  type        = string
  description = "HCP project ID"
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