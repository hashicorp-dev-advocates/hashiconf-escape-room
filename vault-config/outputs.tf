output "token" {
  value     = hcp_vault_cluster_admin_token.vault.token
  sensitive = true
}

output "attandee_password" {
  value     = random_password.attendee.result
  sensitive = true
}