output "openweb_ui_url" {
  value       = "http://${aws_lb.open_webui.dns_name}"
  description = "URL for Open WebUI console"
}

output "open_webui_admin_username" {
  value       = "team-da@hashicorp.com"
  description = "Email for administrative login"
}

resource "random_password" "open_webui_admin_password" {
  length           = 16
  special          = true
  override_special = "!*-"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

output "open_webui_admin_password" {
  value       = random_password.open_webui_admin_password.result
  description = "Password for administrative login"
  sensitive   = true
}

output "ollama_model_id" {
  value = var.model
}

output "ollama_embedding_id" {
  value = var.embeddings
}