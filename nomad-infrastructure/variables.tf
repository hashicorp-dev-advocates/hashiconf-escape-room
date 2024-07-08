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

variable "availability_zones" {
  type        = list(string)
  description = "List of AWS availability zones"
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
}

variable "subnet_ip_prefix" {
  description = "subnet address space prefix"
  type        = string
  default     = "10.0.101"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}