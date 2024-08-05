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
      name          = "waypoint_additional_details"
      options       = []
      user_editable = true
      variable_type = "string"
    },
  ]
}