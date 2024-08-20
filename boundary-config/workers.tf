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

resource "boundary_worker" "session_recording" {
  scope_id    = "global"
  name        = "session-recording"
}


resource "aws_instance" "boundary_worker_session_recording" {

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.private.id
  key_name                    = data.aws_key_pair.deployer.key_name
  associate_public_ip_address = false

  user_data = templatefile("./scripts/boundary-setup.sh", {
    CLUSTER_ID                            = data.terraform_remote_state.hcp.outputs.boundary.cluster_id
    CONTROLLER_GENERATED_ACTIVATION_TOKEN = boundary_worker.session_recording.controller_generated_activation_token
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
