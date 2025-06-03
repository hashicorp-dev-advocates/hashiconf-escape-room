output "openweb_ui_url" {
  value = "http://${aws_lb.open_webui.dns_name}"
}

output "open_webui_username" {
  value = "demos@hashicorp.com"
}

output "open_webui_password" {
  value     = random_password.open_webui_token.result
  sensitive = true
}

