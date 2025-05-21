resource "hcp_vault_cluster_admin_token" "vault" {
  cluster_id = data.terraform_remote_state.hcp.outputs.vault.cluster_id
}

resource "vault_mount" "transform" {
  path = "${var.name}/transform"
  type = "transform"
}

locals {
  address_transformation_name = "address"
  ccn_transformation_name     = "ccn"
  transform_role              = "payments"
}

resource "vault_transform_template" "ccn" {
  path    = vault_mount.transform.path
  name    = local.ccn_transformation_name
  type    = "regex"
  pattern = "(\\d{8,12})\\d{4}"
}

resource "vault_transform_template" "address" {
  path    = vault_mount.transform.path
  name    = local.address_transformation_name
  type    = "regex"
  pattern = "([A-Za-z0-9]+( [A-Za-z0-9]+)+)"
}

data "http" "address" {
  url = "${data.terraform_remote_state.hcp.outputs.vault.public_endpoint}/v1/${vault_mount.transform.path}/transformations/tokenization/${local.address_transformation_name}"

  method = "POST"

  request_body = jsonencode({
    allowed_roles    = [var.application]
    deletion_allowed = true
    convergent       = true
  })

  request_headers = {
    Accept            = "application/json"
    X-Vault-Token     = hcp_vault_cluster_admin_token.vault.token
    X-Vault-Namespace = data.terraform_remote_state.hcp.outputs.vault.namespace
  }

  lifecycle {
    postcondition {
      condition     = contains([200, 201, 204], self.status_code)
      error_message = "Status code invalid"
    }
  }
}

resource "vault_transform_transformation" "ccn" {
  path              = vault_mount.transform.path
  name              = local.ccn_transformation_name
  type              = "masking"
  masking_character = "*"
  template          = vault_transform_template.ccn.name
  allowed_roles     = [var.application]
}

resource "vault_transform_role" "payments" {
  path            = vault_mount.transform.path
  name            = var.application
  transformations = [vault_transform_transformation.ccn.name, local.address_transformation_name]
}

data "vault_policy_document" "transform_decode" {
  rule {
    path         = "${vault_mount.transform.path}/decode/${var.application}"
    capabilities = ["create", "update"]
    description  = "Decode transformations for ${var.application}"
  }
}

resource "vault_policy" "transform_decode" {
  name   = "${var.name}-transform-decode"
  policy = data.vault_policy_document.transform_decode.hcl
}

data "vault_policy_document" "transform_encode" {
  rule {
    path         = "${vault_mount.transform.path}/encode/${var.application}"
    capabilities = ["create", "update"]
    description  = "Encode transformations for ${var.application}"
  }
}

resource "vault_policy" "transform_encode" {
  name   = "${var.name}-transform-encode"
  policy = data.vault_policy_document.transform_encode.hcl
}

data "vault_policy_document" "transform_read" {
  rule {
    path         = "${vault_mount.transform.path}/role/${var.application}"
    capabilities = ["read", "list"]
    description  = "View transformations for ${var.application}"
  }
}

resource "vault_policy" "transform_read" {
  name   = "${var.name}-transform-read"
  policy = data.vault_policy_document.transform_read.hcl
}

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

resource "vault_generic_endpoint" "attendee" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = vault_auth_backend.userpass.path
  ignore_absent_fields = true

  data_json = jsonencode({
    policies = [vault_policy.transform_decode.name, vault_policy.transform_read.name],
    password = random_password.attendee.result
  })
}