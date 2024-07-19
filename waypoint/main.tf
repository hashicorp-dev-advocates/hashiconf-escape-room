data "tfe_organization" "org" {
  name = var.hcp_terraform_organization
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

resource "tfe_team_project_access" "waypoint" {
  access     = "admin"
  team_id    = tfe_team.waypoint.id
  project_id = tfe_project.waypoint.id
}

data "nomad_node_pools" "all" {}

resource "hcp_waypoint_template" "nomad_app" {
  name    = "nomad-container-application"
  summary = "Deploy a container application to Nomad"

  terraform_cloud_workspace_details = {
    name                 = tfe_project.waypoint.name
    terraform_project_id = tfe_project.waypoint.id
  }

  terraform_no_code_module = {
    source  = "app.terraform.io/hashicorp-team-da-beta/app/nomad"
    version = "0.0.0"
  }
}