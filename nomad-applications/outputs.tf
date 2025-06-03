output "openweb_ui_url" {
  value = "http://${aws_lb.open_webui.dns_name}"
}

output "open_webui_username" {
  value = "demos@hashicorp.com"
}

resource "random_password" "open_webui_password" {
  length           = 16
  special          = true
  override_special = "!*-"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

output "open_webui_password" {
  value     = random_password.open_webui_password.result
  sensitive = true
}

