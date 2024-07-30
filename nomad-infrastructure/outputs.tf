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

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}