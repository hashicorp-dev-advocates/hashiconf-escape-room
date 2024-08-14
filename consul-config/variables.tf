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
        clue = "Look at the tag of the Consul shirt."
      }
      tags = null
    },
    {
      service_name = "wishlist"
      meta = {
        clue = "Look under the mug on the shelf."
      }
      tags = null
    },
    {
      service_name = "recommendation"
      meta = {
        clue = "Look at the handle of the umbrella."
      }
      tags = null
    },
    {
      service_name = "notification"
      meta = {
        clue = "Look at the top of the garment rack."
      }
      tags = null
    },
    {
      service_name = "warehouse"
      meta = {
        clue = "Look on the inside cover of the book, “Consul: Up and Running”."
      }
      tags = null
    }
  ]
}