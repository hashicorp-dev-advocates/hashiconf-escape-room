resource "hcp_vault_cluster_admin_token" "vault" {
  cluster_id = data.terraform_remote_state.hcp.outputs.vault.cluster_id
}

module "transit-secrets-engine" {
  source  = "devops-rob/transit-secrets-engine/vault"
  version = "0.1.0"

  path = "transit"
  transit_keys = [
    {
      name                   = "escape-rooms"
      deletion_allowed       = true
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

locals {
  path = var.policies_path == "" ? path.cwd : var.policies_path
  policies = toset([
    for pol in fileset(local.path, "*.{hcl,json}") :
    pol if pol != ".terraform.lock.hcl"
  ])
#  policy_names = [for policy in vault_policy.policies : policy.name]

}

#resource "vault_policy" "policies" {
#  for_each = local.policies
#  name     = each.key
#  policy   = file("${local.path}/${each.key}")
#}

resource "vault_auth_backend" "userpass" {
  type = "userpass"

  tune {
    listing_visibility = "unauth"
  }
}

resource "random_password" "attendee" {
  length  = 10
  special = false

}

#resource "vault_generic_endpoint" "attendee" {
#  depends_on           = [vault_auth_backend.userpass]
#  path                 = "auth/userpass/users/attendee"
#  ignore_absent_fields = true
#
#  data_json = jsonencode({
#    policies = local.policy_names,
#    password = random_password.attendee.result
#  })
#}

