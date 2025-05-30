resource "aws_lb" "open_webui" {
  name               = "${var.name}-open-webui"
  internal           = false
  load_balancer_type = "application"
  security_groups    = data.terraform_remote_state.nomad.outputs.security_groups
  subnets            = data.terraform_remote_state.nomad.outputs.public_subnets
}

data "aws_instances" "nomad_default_clients" {
  instance_tags = {
    purpose      = "nomad-infrastructure"
    nomad_server = "false"
    repository   = var.name
  }

  instance_state_names = ["running"]
}

resource "aws_lb_target_group" "open_webui" {
  name        = "${var.name}-open-webui"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.nomad.outputs.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "open_webui" {
  for_each         = toset(data.aws_instances.nomad_default_clients.ids)
  target_group_arn = aws_lb_target_group.open_webui.arn
  target_id        = each.key
  port             = 8080
}

resource "aws_lb_listener" "open_webui" {
  load_balancer_arn = aws_lb.open_webui.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.open_webui.arn
  }
}