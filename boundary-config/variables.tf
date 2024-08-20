variable "hcp_project_id" {
  description = "HCP Project ID"
}

variable "aws_region" {
  description = "Default AWS region to use"
}

variable "services" {
  description = "The services for which Boundary targets will be created"
}

variable "contestants_password" {
  description = "Password for contestants to use."
}