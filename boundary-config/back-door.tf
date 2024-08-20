resource "boundary_scope" "back_door" {
  scope_id                 = "global"
  name                     = "Developer Advocates"
  description              = "Back door access for Escape room infrastrucure for HashiCorp Developer Advocates only!"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "back_door_project" {

  scope_id                 = boundary_scope.back_door.id
  name                     = "Back door infrastructure"
  description              = "Nomad servers and clients infrastructure. Consul clients infrastructure."
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_credential_store_static" "back_door_creds_store" {

  scope_id    = boundary_scope.back_door_project.id
  name        = "back-door-static-creds-store"
  description = "Static creds store for back door infrastructure}"
}

resource "boundary_credential_ssh_private_key" "back_door_ssh_key" {

  credential_store_id = boundary_credential_store_static.back_door_creds_store.id
  private_key         = data.terraform_remote_state.nomad.outputs.ssh_private_key
  username            = "ubuntu"
  name                = "ssh-key"
}

resource "boundary_target" "nomad_servers" {

  for_each = zipmap(range(length(data.terraform_remote_state.nomad.outputs.nomad_server_private_ip)), data.terraform_remote_state.nomad.outputs.nomad_server_private_ip)

  scope_id     = boundary_scope.back_door_project.id
  type         = "ssh"
  default_port = 22
  name         = "nomad-server-${each.key}"
  address      = each.value

  injected_application_credential_source_ids = [
    boundary_credential_ssh_private_key.back_door_ssh_key.id
  ]

  egress_worker_filter = <<EOF
"/name" == "main"
EOF
}

resource "boundary_target" "nomad_clients" {

  for_each = zipmap(range(length(data.terraform_remote_state.nomad.outputs.nomad_clients_private_ips)), data.terraform_remote_state.nomad.outputs.nomad_clients_private_ips)

  scope_id     = boundary_scope.back_door_project.id
  type         = "ssh"
  default_port = 22
  name         = "nomad-client-${each.key}"
  address      = each.value

  injected_application_credential_source_ids = [
    boundary_credential_ssh_private_key.back_door_ssh_key.id
  ]

  egress_worker_filter = <<EOF
"/name" == "main"
EOF
}
