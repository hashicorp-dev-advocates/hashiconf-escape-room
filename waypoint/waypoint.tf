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

resource "hcp_waypoint_template" "nomad_app" {
  name    = "nomad-container-application"
  summary = "Deploy a container application to Nomad"

  terraform_cloud_workspace_details = {
    name                 = tfe_project.waypoint.name
    terraform_project_id = tfe_project.waypoint.id
  }

  terraform_no_code_module = {
    source  = "app.terraform.io/${tfe_registry_module.nomad_app.namespace}/${tfe_registry_module.nomad_app.name}/${tfe_registry_module.nomad_app.module_provider}"
    version = tfe_no_code_module.nomad_app.version_pin
  }

  readme_markdown_template = base64encode(file("templates/nomad-container-app.md"))

  variable_options = [
    {
      name = "application_count"
      options = [
        "1",
      ]
      user_editable = false
      variable_type = "number"
    },
    {
      name          = "application_name"
      options       = []
      user_editable = true
      variable_type = "string"
    },
    {
      name          = "application_port"
      options       = []
      user_editable = true
      variable_type = "number"
    },
    {
      name          = "image"
      options       = []
      user_editable = true
      variable_type = "string"
    },
    {
      name          = "node_pool"
      options       = data.nomad_node_pools.all.node_pools.*.name
      user_editable = true
      variable_type = "string"
    },
    {
      name = "service_provider"
      options = [
        "nomad",
      ]
      user_editable = false
      variable_type = "string"
    },
    {
      name = "environment_variables"
      options = [
        jsonencode({}),
      ]
      user_editable = false
      variable_type = "map(string)"
    },
    {
      name = "metadata"
      options = [
        jsonencode({
          "waypoint.template" = "nomad-container-application"
        }),
      ]
      user_editable = false
      variable_type = "map(string)"
    },
  ]
}