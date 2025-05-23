resource "boundary_scope" "hashiconf_escape_room_org" {
  scope_id                 = "global"
  name                     = "hashiconf-escape-room"
  description              = "HashiConf Escape Room"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "payments" {
  scope_id                 = boundary_scope.hashiconf_escape_room_org.id
  name                     = "payments-infrastructure"
  description              = "Project containing infrastrure for payments application"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_credential_store_static" "payments" {
  scope_id    = boundary_scope.payments.id
  name        = "payments-static-creds-store"
  description = "Static creds store for payments infrastructure"
}

resource "boundary_credential_ssh_private_key" "payments" {
  credential_store_id = boundary_credential_store_static.payments.id
  private_key         = data.terraform_remote_state.hcp.outputs.escape_room_private_key
  username            = "ubuntu"
  name                = "ssh-key"
}

data "aws_instances" "payments" {
  instance_tags = {
    Name      = "payments"
    Terraform = true
    Packer    = true
  }

  instance_state_names = ["running"]
}

resource "boundary_target" "payments" {
  for_each = toset(data.aws_instances.payments.private_ips)

  scope_id     = boundary_scope.payments.id
  type         = "ssh"
  default_port = 22
  name         = "payments-vm-${each.key}"
  address      = each.value

  injected_application_credential_source_ids = [
    boundary_credential_ssh_private_key.payments.id
  ]

  egress_worker_filter     = <<EOF
"/name" == "${boundary_worker.payments.name}"
EOF
  enable_session_recording = false
}

resource "boundary_auth_method_password" "attendees" {
  scope_id    = boundary_scope.hashiconf_escape_room_org.id
  description = "Password auth method for attendees to use"
  name        = "attendees"
}

resource "boundary_role" "attendees" {
  name = "attendees"

  scope_id = "global"

  grant_strings = [
    "ids=*;type=*;actions=read,list"
  ]

  principal_ids = [
    boundary_user.attendee.id
  ]

}

resource "boundary_role" "attendees_org" {
  name = "attendees-hashiconf-escape-room"

  scope_id = boundary_scope.hashiconf_escape_room_org.id

  grant_strings = [
    "ids=*;type=*;actions=read,list"
  ]

  principal_ids = [
    boundary_user.attendee.id
  ]
}

resource "boundary_role" "attendees_project" {
  scope_id = boundary_scope.payments.id

  grant_strings = [
    "ids=*;type=*;actions=read,list",
    "ids=*;type=target;actions=authorize-session",
    "ids=*;type=session;actions=cancel:self",
  ]

  principal_ids = [
    boundary_user.attendee.id
  ]

  name = "attendees-payments"
}

resource "random_pet" "attendee" {
  length = 1
}

resource "random_password" "attendee" {
  length  = 10
  special = false
}

resource "boundary_account_password" "attendee" {
  auth_method_id = data.boundary_auth_method.auth_method.id
  name           = random_pet.attendee.id
  login_name     = random_pet.attendee.id
  description    = "Password account for escape room attendee to use"
  password       = random_password.attendee.result

}
resource "boundary_user" "attendee" {

  scope_id    = "global"
  name        = boundary_account_password.attendee.login_name
  description = "User for escape room attendee"
  account_ids = [
    boundary_account_password.attendee.id
  ]
}
