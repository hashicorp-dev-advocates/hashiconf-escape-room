variable "hcp_project_id" {
  description = "HCP Project ID"
}

variable "policies_path" {
  type        = string
  default     = ""
  description = "(Optional) The absolute path to directory containing Vault policies. If not set, it defaults to current working directory."
}