data "tfe_oauth_client" "client" {
  organization = var.hcp_terraform_organization
  name         = var.github_user
}

resource "tfe_registry_module" "nomad_app" {
  no_code      = true
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
  organization    = var.hcp_terraform_organization
  registry_module = tfe_registry_module.nomad_app.id
  version_pin     = "0.0.2"

  variable_options {
    name    = "application_count"
    options = [1]
    type    = "number"
  }

  variable_options {
    name    = "application_name"
    options = [""]
    type    = "string"
  }

  variable_options {
    name    = "application_port"
    options = [9090]
    type    = "number"
  }

  variable_options {
    name    = "environment_variables"
    options = ["{}"]
    type    = "map(string)"
  }

  variable_options {
    name    = "image"
    options = [""]
    type    = "string"
  }

  variable_options {
    name    = "metadata"
    options = ["{}"]
    type    = "map(string)"
  }

  variable_options {
    name    = "node_pool"
    options = data.nomad_node_pools.all.node_pools.*.name
    type    = "string"
  }

  variable_options {
    name    = "service_provider"
    options = ["nomad"]
    type    = "string"
  }
}