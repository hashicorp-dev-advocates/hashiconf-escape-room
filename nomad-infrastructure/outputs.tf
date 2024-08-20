#output "nomad_server_private_ip" {
#  value = aws_instance.nomad_servers.*.private_ip
#}
#
#output "nomad_clients_private_ips" {
#  value = aws_instance.nomad_clients.*.private_ip
#}
#
#output "nomad_management_token" {
#  value     = jsondecode(terracurl_request.bootstrap_acl.response).SecretID
#  sensitive = true
#}

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

output "keypair" {
  value = aws_key_pair.deployer.key_name
}

output "security_groups" {
  value = [
    aws_security_group.ssh.id,
    aws_security_group.subnet_allow.id,
    aws_security_group.nomad.id,
    aws_security_group.egress.id
  ]
}

output "default_route_table_id" {
  value = module.vpc.private_route_table_ids
}

output "ssh_public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
}

output "ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
