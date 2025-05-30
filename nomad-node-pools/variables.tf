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
    purpose    = "nomad-node-pools"
  }
}

variable "hcp_packer_bucket_name" {
  type        = string
  description = "HCP Packer bucket name, also used for node pool"
  default     = "ai-ubuntu"
}