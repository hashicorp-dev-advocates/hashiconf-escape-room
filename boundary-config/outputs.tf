output "attendee_username" {
  value = boundary_user.attendee.name
}

output "attendee_password" {
  value     = boundary_account_password.attendee.password
  sensitive = true
}