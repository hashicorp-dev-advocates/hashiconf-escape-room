resource "boundary_worker" "backdoor" {
  scope_id    = "global"
  name        = "backdoor"
  description = "Worker for administrative purposes"
}

resource "boundary_worker" "payments" {
  scope_id    = "global"
  name        = "payments"
  description = "Worker for payments application"
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

resource "aws_instance" "boundary_worker_public_backdoor" {

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = data.terraform_remote_state.nomad.outputs.public_subnets.1
  key_name                    = data.aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  user_data = templatefile("./scripts/boundary-setup.sh", {
    CLUSTER_ID                            = data.terraform_remote_state.hcp.outputs.boundary.cluster_id
    CONTROLLER_GENERATED_ACTIVATION_TOKEN = boundary_worker.backdoor.controller_generated_activation_token
    PURPOSE                               = "backdoor"
  })

  vpc_security_group_ids = local.combined_security_group_ids

  tags = {
    Name = "boundary-worker-backdoor"
  }

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }
}

resource "aws_instance" "boundary_worker_public_payments" {

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = data.terraform_remote_state.nomad.outputs.public_subnets.1
  key_name                    = data.aws_key_pair.hashiconf_escape_room.key_name
  associate_public_ip_address = true

  user_data = templatefile("./scripts/boundary-setup.sh", {
    CLUSTER_ID                            = data.terraform_remote_state.hcp.outputs.boundary.cluster_id
    CONTROLLER_GENERATED_ACTIVATION_TOKEN = boundary_worker.payments.controller_generated_activation_token
    PURPOSE                               = "payments"
  })

  vpc_security_group_ids = local.combined_security_group_ids

  tags = {
    Name = "boundary-worker-payments"
  }

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }
}