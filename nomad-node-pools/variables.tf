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

variable "node_pools" {
  type = map(object({
    bucket_name   = string
    instance_type = string
    key_name      = string
    desired_size  = number
    type          = string
  }))
  description = "A set of node pools to create"
  default = {
    llm = {
      bucket_name   = "ai-ubuntu"
      instance_type = "g6.xlarge"
      key_name      = "deployer-key"
      desired_size  = 1
      type          = "gpu"
    }
    rag = {
      bucket_name   = "ai-ubuntu"
      instance_type = "g6.xlarge"
      key_name      = "deployer-key"
      desired_size  = 1
      type          = "gpu"
    }
  }
}
