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