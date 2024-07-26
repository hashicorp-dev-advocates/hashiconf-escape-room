resource "hcp_vault_cluster_admin_token" "vault" {
  cluster_id = data.terraform_remote_state.hcp.outputs.vault.cluster_id
}

module "transit-secrets-engine" {
  source  = "devops-rob/transit-secrets-engine/vault"
  version = "0.1.0"

  path = "transit"
  transit_keys = [
    {
      name = "escape-rooms"
      deletion_allowed = true
      allow_plaintext_backup = false
      convergent_encryption  = true
      exportable             = false
      derived                = true
      type                   = "aes256-gcm96"
      min_decryption_version = 1
      min_encryption_version = 1
    }
  ]
}