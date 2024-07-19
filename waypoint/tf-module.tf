data "tfe_organization" "org" {
  name = var.hcp_terraform_organization
}

data "tfe_oauth_client" "client" {
  organization = data.tfe_organization.org.name
  name         = var.github_user
}

resource "tfe_registry_module" "nomad_app" {
  organization = data.tfe_organization.org.name
  no_code      = true

  test_config {
    tests_enabled = false
  }

  vcs_repo {
    branch             = "main"
    display_identifier = "${var.github_user}/terraform-nomad-app"
    identifier         = "${var.github_user}/terraform-nomad-app"
    oauth_token_id     = data.tfe_oauth_client.client.oauth_token_id
    tags               = false
  }
}

data "nomad_node_pools" "all" {}