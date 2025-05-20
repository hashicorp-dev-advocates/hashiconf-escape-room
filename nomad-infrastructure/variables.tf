variable "ssh_key" {
  default = "/Users/rbarnes/.ssh/id_rsa.pub"
}

variable "server_count" {
  description = "Number of nomad servers"
  default     = 3
}

variable "client_count" {
  description = "Number of nomad clients"
  default     = 3
}

variable "target_count" {
  description = "Number of boundary target vms"
  default     = 1
}

variable "subnet_ip_prefix" {
  description = "subnet address space prefix"
  type        = string
  default     = "10.0.101"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "name" {
  type        = string
  description = "Name of HCP resources"
  default     = "hashiconf-escape-room"
}

variable "hcp_project_id" {
  type        = string
  description = "HCP project ID"
}

variable "tags" {
  type        = map(string)
  description = "AWS tags to add to resources"
  default = {
    repository = "hashiconf-escape-room"
    purpose    = "nomad-infrastructure"
  }
}

variable "hcp_packer_bucket_name" {
  type        = string
  description = "HCP Packer bucket name, also used for node pool"
  default     = "app-ubuntu"
}