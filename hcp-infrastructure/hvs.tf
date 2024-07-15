resource "hcp_service_principal" "github_actions" {
  name = "github-actions"
}

resource "hcp_service_principal_key" "github_actions" {
  service_principal = hcp_service_principal.github_actions.resource_name
}

resource "hcp_vault_secrets_app" "github_actions" {
  app_name    = "github-actions"
  description = "Secrets for the hashiconf-escape-room repository, specifically for GitHub Actions workflows"
}

resource "hcp_vault_secrets_secret" "hcp_client_id" {
  app_name     = hcp_vault_secrets_app.github_actions.app_name
  secret_name  = "HCP_CLIENT_ID"
  secret_value = hcp_service_principal_key.github_actions.client_id
}

resource "hcp_vault_secrets_secret" "hcp_client_secret" {
  app_name     = hcp_vault_secrets_app.github_actions.app_name
  secret_name  = "HCP_CLIENT_SECRET"
  secret_value = hcp_service_principal_key.github_actions.client_secret
}

resource "hcp_vault_secrets_secret" "hcp_project_id" {
  app_name     = hcp_vault_secrets_app.github_actions.app_name
  secret_name  = "HCP_PROJECT_ID"
  secret_value = var.hcp_project_id
}

resource "hcp_vault_secrets_secret" "aws_role" {
  app_name     = hcp_vault_secrets_app.github_actions.app_name
  secret_name  = "AWS_ROLE"
  secret_value = aws_iam_role.packer.arn
}