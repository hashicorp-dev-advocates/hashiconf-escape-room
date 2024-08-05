variable "hcp_project_id" {
  type        = string
  description = "HCP project ID"
}

variable "image" {
  type        = string
  description = "Container image to use"
  default     = "nicholasjackson/fake-service:v0.26.2"
}

variable "applications" {
  type = map(object({
    waypoint_clues = string
    nomad_clues    = string
    node_pool      = string
    port           = number
  }))
  description = "List of applications and attributes to use"
}