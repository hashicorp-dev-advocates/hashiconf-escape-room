resource "terracurl_request" "nomad_status" {
  method         = "GET"
  name           = "nomad_status"
  response_codes = [200]
  url            = "http://${aws_lb.nomad.dns_name}/v1/status/leader"
  max_retry      = 4
  retry_interval = 10

  depends_on = [
    aws_instance.nomad_servers,
    aws_lb.nomad,
    aws_lb_listener.web,
    aws_lb_target_group.nomad,
    aws_lb_target_group_attachment.nomad
  ]
}

resource "terracurl_request" "bootstrap_acl" {
  method         = "POST"
  name           = "bootstrap"
  response_codes = [200, 201]
  url            = "http://${aws_lb.nomad.dns_name}/v1/acl/bootstrap"

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    terracurl_request.nomad_status,
  ]
}
