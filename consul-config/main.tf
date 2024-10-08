resource "hcp_consul_cluster_root_token" "root" {
  cluster_id = data.terraform_remote_state.hcp.outputs.consul.cluster_id
}


resource "aws_security_group" "consul" {
  vpc_id = data.terraform_remote_state.nomad.outputs.vpc_id
  name   = "consul_port"

  ingress {
    from_port = 8300
    protocol  = "tcp"
    to_port   = 8601

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
    Name = "consul_ports"
  }

}

resource "aws_security_group" "service" {
  vpc_id = data.terraform_remote_state.nomad.outputs.vpc_id
  name   = "fake_service_port"

  ingress {
    from_port = 9090
    protocol  = "tcp"
    to_port   = 9090

    cidr_blocks = [
      "0.0.0.0/0"
    ]
    self = true

  }

  ingress {
    from_port = 20000
    protocol  = "tcp"
    to_port   = 20000

    cidr_blocks = [
      "0.0.0.0/0"
    ]
    self = true

  }

  tags = {
    Name = "fake_service_port"
  }

}


locals {
  combined_security_group_ids = concat(
    data.terraform_remote_state.nomad.outputs.security_groups,
    [aws_security_group.consul.id, aws_security_group.service.id]
  )
}

resource "consul_acl_policy" "policy" {

  for_each = {
    for svc in var.services :
    svc.service_name => svc
  }

  name  = each.value["service_name"]
  rules = <<EOF

# Allow write access to the specific service
service "${each.value["service_name"]}" {
  policy = "write"
}

# Allow write access to the specific service sidecar proxy
service "${each.value["service_name"]}-v1-sidecar-proxy" {
  policy = "write"
}


# Allow the agent to register and update itself
node "" {
  policy = "write"
}

# Allow read access to the specific service
service "${each.value["service_name"]}" {
  policy = "read"
}

# Allow read access to the specific service
service "${each.value["service_name"]}-v1-sidecar-proxy" {
  policy = "read"
}


# Allow read access to the agent node
node "" {
  policy = "read"
}
  EOF

}

resource "consul_acl_token" "services" {
  for_each = {
    for svc in var.services :
    svc.service_name => svc
  }

  description = "ACL token for ${each.value["service_name"]}"

  policies = [
    each.value["service_name"]
  ]

  depends_on = [
    consul_acl_policy.policy
  ]
}

locals {
  service_tokens = {
    for svc_name, svc in data.consul_acl_token_secret_id.services :
    svc_name => svc.secret_id
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "services" {
  public_key = tls_private_key.ssh_key.public_key_openssh
  key_name   = "services"
}

resource "aws_instance" "consul_client" {
  for_each = {
    for svc in var.services :
    svc.service_name => svc
  }

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.private.id
  key_name                    = aws_key_pair.services.key_name
  associate_public_ip_address = false

  user_data = templatefile("./scripts/consul.sh", {
    CA_PUBLIC_KEY     = base64decode(data.terraform_remote_state.hcp.outputs.consul.ca_public_key)
    HCP_CONFIG_FILE   = base64decode(data.terraform_remote_state.hcp.outputs.consul.config_file)
    CONSUL_ROOT_TOKEN = hcp_consul_cluster_root_token.root.secret_id
    SERVICE_NAME      = each.value["service_name"]
    SERVICE_TOKEN     = local.service_tokens[each.key]
    CONSUL_CLUE       = each.value.meta.clue
    BOUNDARY_CLUE     = each.value.boundary_clue
  })

  vpc_security_group_ids = local.combined_security_group_ids

  tags = {
    Name          = each.value["service_name"]
    consul_server = false
  }

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }
}

resource "aws_instance" "bastion" {

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.public.id
  key_name                    = data.aws_key_pair.deployer.key_name
  associate_public_ip_address = true


  vpc_security_group_ids = local.combined_security_group_ids

  tags = {
    Name = "bastion"
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "consul_acl_policy" "read_only" {
  name  = "read-only"
  rules = <<EOF
operator = "read"
partition_prefix "" {
  namespace_prefix "" {
    service_prefix "" {
      policy = "read"
    }
    node_prefix "" {
      policy = "read"
    }
  }
}
  EOF
}

resource "consul_acl_token" "read_only" {
  description = "ACL token for read-only to services"

  policies = [
    consul_acl_policy.read_only.name
  ]
}

data "consul_acl_token_secret_id" "read_only" {
  accessor_id = consul_acl_token.read_only.id
}