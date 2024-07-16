output "nomad_server_private_ip" {
  value = aws_instance.nomad_servers.*.private_ip
}

output "nomad_clients_private_ips" {
  value = aws_instance.nomad_clients.*.private_ip
}

output "nomad_management_token" {
  value     = jsondecode(terracurl_request.bootstrap_acl.response).SecretID
  sensitive = true
}

output "nomad_ui" {
  value = "http://${aws_lb.nomad.dns_name}"
}