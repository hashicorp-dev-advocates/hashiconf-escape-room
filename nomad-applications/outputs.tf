output "openweb_ui_url" {
  value = "http://${aws_lb.open_webui.dns_name}"
}