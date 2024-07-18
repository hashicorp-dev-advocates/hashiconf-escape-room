variable "application_name" {
  type        = string
  description = "Name of application"
}

variable "application_port" {
  type        = number
  description = "Port of application"
}

variable "application_count" {
  type        = number
  description = "Number of instances for application"
  default     = 1
}

variable "node_pool" {
  type        = string
  description = "Node pool for application"
  default     = "default"
}

variable "driver" {
  type        = string
  description = "Nomad driver to run application"
  validation {
    condition     = contains(["exec", "docker"], var.driver)
    error_message = "Must be of `exec` or `docker` driver"
  }
}

variable "cpu" {
  type        = number
  description = "CPU for application"
  default     = 20
}

variable "memory" {
  type        = number
  description = "Memory for application"
  default     = 10
}

variable "command" {
  type        = string
  description = "Command to run application"
  default     = null
}

variable "args" {
  type        = list(string)
  description = "Arguments to pass to command when running application"
  default     = null
}

variable "metadata" {
  type        = map(string)
  description = "Metadata for application"
  default     = {}
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for application"
  default     = {}
}

variable "image" {
  type        = string
  description = "Container image for application"
}

variable "service_provider" {
  type        = string
  description = "Nomad service provider, must be consul or nomad"
  default     = "consul"
  validation {
    condition     = contains(["consul", "nomad"], var.service_provider)
    error_message = "Must be of `consul` or `nomad` provider"
  }
}