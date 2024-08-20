resource "boundary_worker" "main" {
  scope_id    = "global"
  name        = "main"
  description = "main private subnet worker"
}

resource "aws_security_group" "boundary" {
  vpc_id = data.terraform_remote_state.nomad.outputs.vpc_id
  name   = "boundary"

  ingress {
    from_port = 9202
    protocol  = "tcp"
    to_port   = 9202

    cidr_blocks = [
      "0.0.0.0/0"
    ]
    self = true

  }


  egress {
    from_port = 0
    protocol  = "tcp"
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0"
    ]

    self = true
  }

  tags = {
    Name = "boundary_port"
  }

}

locals {
  combined_security_group_ids = concat(
    data.terraform_remote_state.nomad.outputs.security_groups,
    [aws_security_group.boundary.id]
  )
}

resource "aws_instance" "boundary_worker_public" {

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.private.id
  key_name                    = data.aws_key_pair.deployer.key_name
  associate_public_ip_address = false

  user_data = templatefile("./scripts/boundary-setup.sh", {
    CLUSTER_ID                            = data.terraform_remote_state.hcp.outputs.boundary.cluster_id
    CONTROLLER_GENERATED_ACTIVATION_TOKEN = boundary_worker.main.controller_generated_activation_token
  })

  vpc_security_group_ids = local.combined_security_group_ids

  tags = {
    Name = "Boundary Worker Private"
  }

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }
}

resource "boundary_scope" "hashiconf_escape_room_org" {
  scope_id                 = "global"
  name                     = "HashiConf Escape Room Org"
  description              = "Org containing infrastrure"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

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


resource "aws_s3_bucket" "hashiconf" {
  bucket = "hashiconf-recordings"

}

resource "aws_s3_access_point" "backend_recordings" {
  provider = "aws.boundary"
  bucket   = aws_s3_bucket.hashiconf.bucket
  name     = aws_s3_bucket.hashiconf.bucket

  vpc_configuration {
    vpc_id = data.terraform_remote_state.nomad.outputs.vpc_id
  }
}

#resource "boundary_storage_bucket" "backend_recordings" {
#  name        = "hashiconf_escape_room"
#  description = "All the recordings for HashiConf Escape Room"
#  scope_id    = boundary_scope.hashiconf_escape_room_org.id
#  plugin_name = "aws"
#  bucket_name = aws_s3_bucket.backend_recordings.bucket
#  attributes_json = jsonencode({
#    "region"                      = var.aws_region
#    "disable_credential_rotation" = true
#    "role_arn" = data.terraform_remote_state.hcp.outputs.boundary_session_recording_iam
#  })
#
#  secrets_json = jsonencode({})
#
#  worker_filter = <<EOF
#"/name" == "main"
#EOF
#
#
#  depends_on = [
#    aws_s3_access_point.backend_recordings,
#    aws_instance.boundary_worker_public
#  ]
#}