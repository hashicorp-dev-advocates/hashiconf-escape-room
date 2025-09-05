# Create ML Pipeline namesapce
resource "nomad_namespace" "ml_pipeline" {
  name        = "ml-pipeline"
  description = "Environment for Machine Learning pipelines"
  meta        = {
    owner = "Dev Advocates"
  }
}

# Contestants ACL Policy
resource "nomad_acl_policy" "contestants" {
  name        = "contestants"
  description = "Submite ML pipeline jobs"

  rules_hcl = <<EOT
namespace "${nomad_namespace.ml_pipeline.name}" {
  capabilities = [
    "list-jobs",
    "submit-job",
    "read-job",
    "host-volume-read",
    "host-volume-create",
    "host-volume-write",
    "host-volume-register"
  ]
}
EOT
}

# ACL token to use within Instruqt
resource "nomad_acl_token" "contestants" {
  name     = nomad_acl_policy.contestants.name
  type     = "client"
  policies = [nomad_acl_policy.contestants.name]
  expiration_ttl = "30d"
}
