resource "hcp_service_principal" "github_actions" {
  name = "github-actions"
}

resource "hcp_project_iam_binding" "github_actions" {
  project_id   = var.hcp_project_id
  principal_id = hcp_service_principal.github_actions.resource_id
  role         = "roles/contributor"
}

resource "hcp_service_principal_key" "github_actions" {
  service_principal = hcp_service_principal.github_actions.resource_name
}

resource "github_actions_secret" "hcp_service_principal_client_id" {
  repository      = var.repositories.0
  secret_name     = "HCP_CLIENT_ID"
  plaintext_value = hcp_service_principal_key.github_actions.client_id
}

resource "github_actions_secret" "hcp_service_principal_client_secret" {
  repository      = var.repositories.0
  secret_name     = "HCP_CLIENT_SECRET"
  plaintext_value = hcp_service_principal_key.github_actions.client_secret
}

resource "github_actions_variable" "aws_region" {
  repository    = var.repositories.0
  variable_name = "AWS_REGION"
  value         = var.aws_region
}

resource "github_actions_variable" "aws_role" {
  repository    = var.repositories.0
  variable_name = "AWS_ROLE"
  value         = aws_iam_role.github_actions.arn
}