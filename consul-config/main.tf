resource "hcp_consul_cluster_root_token" "root" {
  cluster_id = data.terraform_remote_state.hcp.outputs.consul.cluster_id
}

#resource "consul_node" "nodes" {
#  for_each = {
#    for svc in var.services :
#    svc.service_name => svc
#  }
#
#  address = each.value["node_address"]
#  name    = each.value["node_name"]
#}
#
#resource "consul_service" "services" {
#
#  for_each = {
#    for svc in var.services :
#    svc.service_name => svc
#  }
#
#  name = each.value["service_name"]
#  node = each.value["node_name"]
#  meta = each.value["meta"]
#  port = each.value["port"]
#  tags = each.value["tags"]
#
#  #  check {
#  #    check_id = "test"
#  #    interval = "10"
#  #    name     = "test"
#  #    timeout  = "10"
#  #  }
#
#  depends_on = [
#    consul_node.nodes
#  ]
#}

resource "aws_security_group" "consul" {
  vpc_id = data.terraform_remote_state.nomad.outputs.vpc_id
  name   = "consul_port"

  ingress {
    from_port = 8500
    protocol  = "tcp"
    to_port   = 8502

    cidr_blocks = [
      "0.0.0.0/0"
    ]
    self = true

  }

  tags = {
    Name = "consul_port"
  }

}

locals {
  combined_security_group_ids = concat(
    data.terraform_remote_state.nomad.outputs.security_groups,
    [aws_security_group.consul.id]
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

# Allow the agent to register and update itself
node "" {
  policy = "write"
}

# Allow read access to the specific service
service "${each.value["service_name"]}" {
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

resource "aws_instance" "consul_client" {
  for_each = {
    for svc in var.services :
    svc.service_name => svc
  }

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.private.id
  key_name                    = data.aws_key_pair.deployer.key_name
  associate_public_ip_address = false

  user_data = templatefile("./scripts/consul.sh", {
    CA_PUBLIC_KEY     = base64decode(data.terraform_remote_state.hcp.outputs.consul.ca_public_key)
    HCP_CONFIG_FILE   = base64decode(data.terraform_remote_state.hcp.outputs.consul.config_file)
    CONSUL_ROOT_TOKEN = hcp_consul_cluster_root_token.root.secret_id
    SERVICE_NAME      = each.value["service_name"]
    SERVICE_TOKEN     = local.service_tokens[each.key]
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
    Name          ="bastion"
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}