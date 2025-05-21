variable "hcp_project_id" {
  description = "HCP Project ID"
}

variable "policies_path" {
  type        = string
  default     = ""
  description = "(Optional) The absolute path to directory containing Vault policies. If not set, it defaults to current working directory."
}

variable "name" {
  type        = string
  default     = "payments"
  description = "Name of business unit, used for Vault mount path"
}

variable "application" {
  type        = string
  default     = "payments"
  description = "Name of application, used for Vault role"
}