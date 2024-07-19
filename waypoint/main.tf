data "tfe_organization" "org" {
  name = var.hcp_terraform_organization
}

resource "tfe_team" "waypoint" {
  name         = "hashiconf-escape-room-waypoint"
  organization = data.tfe_organization.org.name
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
    name                 = "nomad-app"
    terraform_project_id = tfe_project.waypoint.id
  }

  terraform_no_code_module = {
    source  = "app.terraform.io/hashicorp-team-da-beta/app/nomad"
    version = "0.0.0"
  }

  variable_options = [
    {
      name          = "application_name"
      variable_type = "string"
    },
    {
      name          = "application_port"
      variable_type = "number"
    },
    {
      name          = "image"
      variable_type = "string"
    },
    {
      name          = "metadata"
      variable_type = "map(string)"
    },
    {
      name          = "node_pool"
      variable_type = "string"
      options       = [for pool in data.nomad_node_pools.all.node_pools : pool.name]
      user_editable = false
    }
    ,
    {
      name          = "driver"
      variable_type = "string"
      options       = ["docker"]
      user_editable = false
    },
    {
      name          = "service_provider"
      variable_type = "string"
      options       = ["nomad"]
      user_editable = false
    }
  ]
}