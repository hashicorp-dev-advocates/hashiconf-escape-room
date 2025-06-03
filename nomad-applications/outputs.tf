output "openweb_ui_url" {
  value = "http://${aws_lb.open_webui.dns_name}"
}

output "open_webui_admin_username" {
  value = "team-da@hashicorp.com"
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
  value     = random_password.open_webui_admin_password.result
  sensitive = true
}

