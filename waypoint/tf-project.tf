resource "nomad_acl_policy" "waypoint" {
  name        = "waypoint"
  description = "Submit jobs to the default environment using Waypoint"

  rules_hcl = <<EOT
namespace "default" {
  policy       = "write"

  variables {
    path "*" {
      capabilities = ["write", "read", "destroy"]
    }
  }
}
EOT
}

resource "nomad_acl_token" "waypoint" {
  name     = "waypoint"
  type     = "client"
  policies = [nomad_acl_policy.waypoint.name]
  global   = true
}

resource "tfe_team" "waypoint" {
  name         = "hashiconf-escape-room-waypoint"
  organization = data.tfe_organization.org.name
  visibility   = "organization"
  organization_access {
    read_workspaces   = false
    read_projects     = false
    manage_workspaces = false
  }
}

resource "time_rotating" "waypoint_token" {
  rotation_days = 120
}

resource "tfe_team_token" "waypoint" {
  team_id    = tfe_team.waypoint.id
  expired_at = time_rotating.waypoint_token.rotation_rfc3339
}

resource "hcp_waypoint_tfc_config" "org" {
  token        = tfe_team_token.waypoint.token
  tfc_org_name = tfe_team.waypoint.organization
}

resource "tfe_project" "waypoint" {
  organization = data.tfe_organization.org.name
  name         = "${var.hcp_terraform_project}-apps"
}

resource "tfe_variable_set" "nomad" {
  name         = "${tfe_project.waypoint.name}-nomad"
  description  = "Nomad connection details"
  organization = data.tfe_organization.org.name
}

resource "tfe_variable" "nomad_addr" {
  key             = "NOMAD_ADDR"
  value           = data.terraform_remote_state.nomad.outputs.nomad_ui
  category        = "env"
  description     = "Nomad cluster address"
  variable_set_id = tfe_variable_set.nomad.id
}

resource "tfe_variable" "nomad_token" {
  key             = "NOMAD_TOKEN"
  value           = nomad_acl_token.waypoint.secret_id
  category        = "env"
  description     = "Nomad cluster token"
  variable_set_id = tfe_variable_set.nomad.id
  sensitive       = true
}

resource "tfe_project_variable_set" "test" {
  project_id      = tfe_project.waypoint.id
  variable_set_id = tfe_variable_set.nomad.id
}

resource "tfe_team_project_access" "waypoint" {
  access     = "admin"
  team_id    = tfe_team.waypoint.id
  project_id = tfe_project.waypoint.id
}