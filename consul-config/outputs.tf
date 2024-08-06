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

output "ssh_public_key" {
  value = tls_private_key.ssh_key.public_key_pem
}

output "ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}