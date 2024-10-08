output "nomad_app_template_id" {
  value       = data.hcp_waypoint_template.nomad_app.id
  description = "Waypoint template ID for Nomad application"
}

output "nomad_read_only_token" {
  value       = nomad_acl_token.read_only.secret_id
  sensitive   = true
  description = "Nomad read-only token"
}

output "nomad_waypoint_actions_token" {
  value       = nomad_acl_token.waypoint_actions.secret_id
  sensitive   = true
  description = "Nomad token for Waypoint Actions"
}