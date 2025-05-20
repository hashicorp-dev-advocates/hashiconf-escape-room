data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "hashiconf-escape-rooms"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
  }
}

resource "aws_lb" "nomad" {
  name               = "nomad-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id, aws_security_group.nomad.id, aws_security_group.egress.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "nomad-lb"
  }
}

resource "aws_lb_target_group" "nomad" {
  name        = "nomad-tg"
  port        = 4646
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/v1/agent/health"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200"
  }


}
resource "aws_lb_target_group_attachment" "nomad" {
  count            = var.server_count
  target_group_arn = aws_lb_target_group.nomad.arn
  target_id        = aws_instance.nomad_servers[count.index].id
  port             = 4646
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.nomad.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad.arn
  }
}

data "hcp_hvn" "main" {
  hvn_id = data.terraform_remote_state.hcp.outputs.hvn.id
}

resource "hcp_aws_network_peering" "nomad" {
  hvn_id          = data.hcp_hvn.main.hvn_id
  peering_id      = "${var.name}-nomad"
  peer_vpc_id     = module.vpc.vpc_id
  peer_account_id = module.vpc.vpc_owner_id
  peer_vpc_region = var.aws_region
}

resource "hcp_hvn_route" "main-to-nomad" {
  hvn_link         = data.hcp_hvn.main.self_link
  hvn_route_id     = "main-to-dev"
  destination_cidr = module.vpc.vpc_cidr_block
  target_link      = hcp_aws_network_peering.nomad.self_link
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.nomad.provider_peering_id
  auto_accept               = true
}

resource "aws_route" "hvn_route" {
  for_each = toset(module.vpc.private_route_table_ids)

  route_table_id            = each.key
  destination_cidr_block    = data.hcp_hvn.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}
