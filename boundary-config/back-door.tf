resource "boundary_scope" "back_door" {
  scope_id                 = "global"
  name                     = "backdoor"
  description              = "Backdoor access to infrastructure - for administrative purposes only"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "nomad" {
  scope_id                 = boundary_scope.back_door.id
  name                     = "nomad"
  description              = "Nomad servers and clients infrastructure"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_credential_store_static" "nomad" {

  scope_id    = boundary_scope.nomad.id
  name        = "nomad-static-creds-store"
  description = "Static creds store for Nomad clients and servers"
}

resource "boundary_credential_ssh_private_key" "nomad" {

  credential_store_id = boundary_credential_store_static.nomad.id
  private_key         = data.terraform_remote_state.nomad.outputs.ssh_private_key
  username            = "ubuntu"
  name                = "ssh-key"
}

resource "boundary_target" "nomad_servers" {

  for_each = zipmap(range(length(data.terraform_remote_state.nomad.outputs.nomad_server_private_ip)), data.terraform_remote_state.nomad.outputs.nomad_server_private_ip)

  scope_id     = boundary_scope.nomad.id
  type         = "ssh"
  default_port = 22
  name         = "nomad-server-${each.key}"
  address      = each.value

  injected_application_credential_source_ids = [
    boundary_credential_ssh_private_key.nomad.id
  ]

  egress_worker_filter = <<EOF
"/name" == "${boundary_worker.backdoor.name}"
EOF
}

resource "boundary_target" "nomad_clients" {

  for_each = zipmap(range(length(data.terraform_remote_state.nomad.outputs.nomad_clients_private_ips)), data.terraform_remote_state.nomad.outputs.nomad_clients_private_ips)

  scope_id     = boundary_scope.nomad.id
  type         = "ssh"
  default_port = 22
  name         = "nomad-client-${each.key}"
  address      = each.value

  injected_application_credential_source_ids = [
    boundary_credential_ssh_private_key.nomad.id
  ]

  egress_worker_filter = <<EOF
"/name" == "${boundary_worker.backdoor.name}"
EOF
}

data "aws_instances" "nomad_clients_gpu" {
  instance_tags = {
    repository = "hashiconf-escape-room"
    Purpose    = "gpu"
  }

  instance_state_names = ["running"]
}


resource "boundary_target" "nomad_clients_gpu" {
  for_each = toset(data.aws_instances.nomad_clients_gpu.private_ips)

  scope_id     = boundary_scope.nomad.id
  type         = "ssh"
  default_port = 22
  name         = "nomad-client-gpu-${each.key}"
  address      = each.value

  injected_application_credential_source_ids = [
    boundary_credential_ssh_private_key.nomad.id
  ]

  egress_worker_filter = <<EOF
"/name" == "${boundary_worker.backdoor.name}"
EOF
}
