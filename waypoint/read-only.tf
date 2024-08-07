resource "nomad_acl_policy" "read_only" {
  name        = "read-only"
  description = "Read only policy for Nomad UI"

  rules_hcl = <<EOT
namespace "default" {
  policy       = "read"

  variables {
    path "*" {
      capabilities = ["read"]
    }
  }
}
EOT
}

resource "nomad_acl_token" "read_only" {
  name     = "read-only"
  type     = "client"
  policies = [nomad_acl_policy.read_only.name]
  global   = true
}