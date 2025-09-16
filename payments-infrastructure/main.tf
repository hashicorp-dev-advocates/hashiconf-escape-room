data "hcp_packer_version" "packer" {
  bucket_name  = "app-ubuntu"
  channel_name = "latest"
}

data "hcp_packer_artifact" "packer" {
  bucket_name         = "app-ubuntu"
  platform            = "aws"
  version_fingerprint = data.hcp_packer_version.packer.fingerprint
  region              = var.aws_region
}

data "tfe_outputs" "hcp_infrastructure" {
  organization = "hashicorp-team-da-beta"
  workspace    = "hcp-infrastructure"
}

data "tfe_outputs" "nomad_infrastructure" {
  organization = "hashicorp-team-da-beta"
  workspace    = "nomad-infrastructure"
}

resource "aws_instance" "payments" {
  ami                         = data.hcp_packer_artifact.packer.external_identifier
  instance_type               = "t2.micro"
  subnet_id                   = data.tfe_outputs.nomad_infrastructure.values.private_subnets.1
  key_name                    = data.tfe_outputs.hcp_infrastructure.values.escape_room_key_pair
  associate_public_ip_address = false

  vpc_security_group_ids = data.tfe_outputs.nomad_infrastructure.values.security_groups

  user_data = file("setup.sh")
tags = {
    Name         = "payments"
    Purpose      = "boundary-target"
    Terraform    = true
    Packer       = true
    nomad_server = false
  }
}