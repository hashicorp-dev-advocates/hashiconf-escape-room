data "tfe_organization" "org" {
  name = var.hcp_terraform_organization
}

data "tfe_project" "project" {
  organization = var.hcp_terraform_organization
  name         = var.hcp_terraform_project
}

data "nomad_node_pools" "all" {}

resource "hcp_waypoint_template" "nomad_app" {
  name    = "nomad-container-application"
  summary = "Deploy a container application to Nomad"

  terraform_cloud_workspace_details = {
    name                 = "nomad-app"
    organization         = data.tfe_organization.org.external_id
    terraform_project_id = data.tfe_project.project.id
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