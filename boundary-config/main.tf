resource "boundary_scope" "hashiconf_escape_room_org" {
  scope_id                 = "global"
  name                     = "HashiConf Escape Room Org"
  description              = "Org containing infrastrure"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "hashiconf_escape_room_projects" {
  for_each = {
    for svc in var.services :
    svc.service_name => svc
  }

  scope_id                 = boundary_scope.hashiconf_escape_room_org.id
  name                     = "${each.value["service_name"]}-infrastructure"
  description              = "Project containing infrastrure for ${each.value["service_name"]}"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_credential_store_static" "creds_store" {

  for_each = {
    for svc in var.services :
    svc.service_name => svc
  }

  scope_id    = boundary_scope.hashiconf_escape_room_projects[each.key].id
  name        = "${each.value["service_name"]}-static-creds-store"
  description = "Static creds store for ${each.value["service_name"]}"
}

resource "boundary_credential_ssh_private_key" "ssh_key" {
  for_each = {
    for svc in var.services :
    svc.service_name => svc
  }

  credential_store_id = boundary_credential_store_static.creds_store[each.key].id
  private_key         = data.terraform_remote_state.consul.outputs.ssh_private_key
  username            = "ubuntu"
  name                = "ssh-key"
}


resource "boundary_target" "targets" {

  for_each = {
    for svc in var.services :
    svc.service_name => svc
  }

  scope_id     = boundary_scope.hashiconf_escape_room_projects[each.key].id
  type         = "ssh"
  default_port = 22
  name         = each.value["service_name"]
  address      = data.terraform_remote_state.consul.outputs.services_map[each.value["service_name"]]

  injected_application_credential_source_ids = [
    boundary_credential_ssh_private_key.ssh_key[each.key].id
  ]

  egress_worker_filter = <<EOF
"/name" == "main"
EOF
}

resource "boundary_auth_method_password" "contestants" {
  scope_id    = boundary_scope.hashiconf_escape_room_org.id
  description = "Password auth method for contestants to use"
  name        = "Contestants Login"
}

resource "boundary_role" "contestants" {

  scope_id = boundary_scope.hashiconf_escape_room_org.id
  #  grant_scope_id = boundary_scope.hashiconf_escape_room_org.id

  grant_strings = [
    "ids=*;type=*;actions=read"
  ]

  principal_ids = [
    boundary_user.contestants.id
  ]
}


resource "boundary_account_password" "contestants" {
  auth_method_id = boundary_auth_method_password.contestants.id
  name           = "contestants"
  login_name     = "contestants"
  description    = "Password account for escape room contestants to use"
  password       = var.contestants_password

}
resource "boundary_user" "contestants" {

  scope_id    = boundary_scope.hashiconf_escape_room_org.id
  name        = "contestants"
  description = "User for escape room contestants to use"
}
