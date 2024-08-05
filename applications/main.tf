data "hcp_waypoint_template" "nomad_app" {
  name = "nomad-container-application"
}

resource "hcp_waypoint_application" "apps" {
  for_each    = nonsensitive(var.applications)
  name        = each.key
  template_id = data.hcp_waypoint_template.nomad_app.id
  application_input_variables = [
    {
      name          = "application_port"
      value         = each.value.port
      variable_type = "number"
    },
    {
      name          = "waypoint_additional_details"
      value         = each.value.waypoint_clues
      variable_type = "string"
    },
    {
      name          = "node_pool"
      value         = each.value.node_pool
      variable_type = "string"
    },
    {
      name          = "image"
      value         = var.image
      variable_type = "string"
    }
  ]
}