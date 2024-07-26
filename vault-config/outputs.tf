output "token" {
  value     = hcp_vault_cluster_admin_token.vault.token
  sensitive = true
}
