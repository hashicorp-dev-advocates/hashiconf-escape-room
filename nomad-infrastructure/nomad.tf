resource "terracurl_request" "nomad_status" {
  method         = "GET"
  name           = "nomad_status"
  response_codes = [200]
  url            = "http://${aws_lb.nomad.dns_name}:4646/v1/status/leader"
  max_retry = 4
  retry_interval = 10

  depends_on = [
    aws_instance.nomad_servers,
  ]
}

resource "terracurl_request" "bootstrap_acl" {
  method         = "POST"
  name           = "bootstrap"
  response_codes = [200, 201]
  url            = "http://${aws_lb.nomad.dns_name}:4646/v1/acl/bootstrap"

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    terracurl_request.nomad_status,
  ]
}
