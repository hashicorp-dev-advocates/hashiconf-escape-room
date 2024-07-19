data "tfe_organization" "org" {
  name = var.hcp_terraform_organization
}

resource "tfe_registry_module" "nomad_app" {
  for_each     = var.tf_module_repositories
  organization = data.tfe_organization.org.id

  test_config {
    tests_enabled = false
  }

  vcs_repo {
    display_identifier         = "${var.github_user}/${each.value}"
    identifier                 = "${var.github_user}/${each.value}"
    github_app_installation_id = var.tf_github_app_installation_id
    branch                     = "main"
    tags                       = false
  }
}

resource "tfe_no_code_module" "nomad_app" {
  for_each        = tfe_registry_module.nomad_app
  organization    = data.tfe_organization.org.id
  registry_module = each.value.id
}