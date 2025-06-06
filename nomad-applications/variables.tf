variable "model" {
  type        = string
  description = "Model to pull in ollama, exposed as Nomad action. Refer to https://ollama.com/library."
  default     = "granite3.3:2b"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "name" {
  type        = string
  description = "Name for resources"
  default     = "hashiconf-escape-room"
}

variable "embeddings" {
  type        = string
  description = "Embedding models to pull in ollama, exposed as Nomad action."
  default     = "granite-embedding:30m"
}