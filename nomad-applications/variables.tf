variable "model" {
  type        = string
  description = "Model to pull in ollama, exposed as Nomad action. Refer to https://ollama.com/library."
  default     = "granite3.3:8b"
}