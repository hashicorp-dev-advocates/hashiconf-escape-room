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
        meta         = map(string)
        tags         = list(string)
      }
    )
  )
  default = [
    {
      service_name = "catalog"
      meta = {
        default = "true"
      }
      tags = null
    },
    {
      service_name = "wishlist"
      meta = {
        default = "true"
      }
      tags = null
    },
    {
      service_name = "recommendation"
      meta = {
        default = "true"
      }
      tags = null
    },
    {
      service_name = "notification"
      meta = {
        default = "true"
      }
      tags = null
    },
    {
      service_name = "warehouse"
      meta = {
        default = "true"
      }
      tags = null
    }
  ]
}