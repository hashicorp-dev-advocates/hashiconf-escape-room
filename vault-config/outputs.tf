output "test" {
  value = data.terraform_remote_state.hcp.outputs.vault[public_endpoint]
}