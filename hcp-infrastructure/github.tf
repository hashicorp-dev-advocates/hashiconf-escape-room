resource "hcp_service_principal" "github_actions" {
  name = "github-actions"
}

resource "hcp_project_iam_binding" "github_actions" {
  project_id   = var.hcp_project_id
  principal_id = hcp_service_principal.github_actions.resource_id
  role         = "roles/contributor"
}

resource "hcp_iam_workload_identity_provider" "github_actions" {
  name              = "github-actions"
  service_principal = hcp_service_principal.github_actions.resource_name
  description       = "Allow HCP Packer deploy workflow to access github actions service principal"

  oidc = {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  conditional_access = "jwt_claims.repository == `${var.github_user}/${var.repositories.0}` and jwt_claims.ref == `refs/heads/main`"
}