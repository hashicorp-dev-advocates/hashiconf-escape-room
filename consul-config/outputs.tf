output "consul_token" {
  value     = hcp_consul_cluster_root_token.root.secret_id
  sensitive = true
}

output "consul_addr" {
  value = data.terraform_remote_state.hcp.outputs.consul.public_endpoint
}

output "hcp_file" {
  value = data.terraform_remote_state.hcp.outputs.consul.config_file
}

output "client_ip_addresses" {
  value = aws_instance.consul_client.private_dns
}