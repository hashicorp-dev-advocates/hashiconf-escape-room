variable "hcp_project_id" {
  description = "HCP Project ID"
}

variable "aws_region" {
  description = "Default AWS region to use"
}

variable "services" {
  type = list(
    object(
      {
        service_name = string
        node_address = string
        node_name    = string
        port         = number
        meta         = map(string)
        tags         = list(string)
      }
    )
  )
  default = [
    {
      service_name = "google"
      node_address = "www.google.com"
      node_name    = "google"
      port         = 80
      meta = {
        default = "true"
      }
      tags = null
    }
  ]
}