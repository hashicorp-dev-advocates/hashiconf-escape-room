data "tfe_oauth_client" "client" {
  organization = var.hcp_terraform_organization
  name         = var.github_user
}

resource "tfe_registry_module" "nomad_app" {
  organization = var.hcp_terraform_organization

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

resource "tfe_no_code_module" "nomad_app" {
  enabled         = true
  organization    = "hashicorp-team-da-beta"
  registry_module = "mod-wWQ9jhqYLoBCJM6T"
  version_pin     = "0.0.2"
}
