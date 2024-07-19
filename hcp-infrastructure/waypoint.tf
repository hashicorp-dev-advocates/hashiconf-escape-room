data "tfe_organization" "org" {
  name = var.hcp_terraform_organization
}

data "tfe_oauth_client" "client" {
  organization = var.hcp_terraform_organization
  name         = var.github_user
}

resource "tfe_registry_module" "nomad_app" {
  for_each     = var.tf_module_repositories
  organization = data.tfe_organization.org.id

  test_config {
    tests_enabled = false
  }

  vcs_repo {
    display_identifier = "${var.github_user}/${each.value}"
    identifier         = "https://github.com/${var.github_user}/${each.value}"
    oauth_token_id     = data.tfe_oauth_client.client.oauth_token_id
    branch             = "main"
    tags               = false
  }
}

resource "tfe_no_code_module" "nomad_app" {
  for_each        = tfe_registry_module.nomad_app
  organization    = data.tfe_organization.org.id
  registry_module = each.value.id
}