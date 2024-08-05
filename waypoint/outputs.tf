output "nomad_app_template_id" {
  value       = data.hcp_waypoint_template.nomad_app.id
  description = "Waypoint template ID for Nomad application"
}