resource "nomad_acl_policy" "read_only" {
  name        = "read-only"
  description = "Read only policy for Nomad UI"

  rules_hcl = <<EOT
namespace "default" {
  policy       = "read"
  capabilities = ["alloc-exec"]
}
EOT
}

resource "nomad_acl_token" "read_only" {
  name     = "read-only"
  type     = "client"
  policies = [nomad_acl_policy.read_only.name]
  global   = true
}

resource "nomad_acl_policy" "waypoint_actions" {
  name        = "waypoint-actions"
  description = "Policy for Waypoint actions"

  rules_hcl = <<EOT
namespace "default" {
  policy       = "scale"
}
EOT
}

resource "nomad_acl_token" "waypoint_actions" {
  name     = "waypoint-actions"
  type     = "client"
  policies = [nomad_acl_policy.waypoint_actions.name]
  global   = true
}