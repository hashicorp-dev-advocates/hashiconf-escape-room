data "hcp_packer_version" "packer" {
  for_each     = var.node_pools
  bucket_name  = each.value.bucket_name
  channel_name = "latest"
}

data "hcp_packer_artifact" "packer" {
  for_each            = var.node_pools
  bucket_name         = each.value.bucket_name
  platform            = "aws"
  version_fingerprint = data.hcp_packer_version.packer[each.key].fingerprint
  region              = var.aws_region
}

resource "aws_iam_role" "nomad" {
  name = "nomad-node-pool-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "nomad" {
  name        = "nomad-node-pool-policy"
  description = "IAM policy for Nomad node pool instances"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nomad" {
  role       = aws_iam_role.nomad.name
  policy_arn = aws_iam_policy.nomad.arn
}

resource "aws_iam_instance_profile" "nomad" {
  name = "nomad-node-pool-profile"
  role = aws_iam_role.nomad.name
}

resource "aws_launch_template" "node_pool" {
  for_each      = var.node_pools
  name_prefix   = "${var.name}-${each.key}"
  image_id      = data.hcp_packer_artifact.packer[each.key].external_identifier
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.nomad.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge({
      NodePool = each.key,
      Name     = var.name
    }, var.tags)
  }

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  vpc_security_group_ids = data.terraform_remote_state.nomad.outputs.security_groups

  user_data = base64encode(file("./setup.sh"))
}

resource "aws_autoscaling_group" "node_pool" {
  for_each    = var.node_pools
  name_prefix = "${var.name}-${each.key}"

  launch_template {
    id      = aws_launch_template.node_pool[each.key].id
    version = aws_launch_template.node_pool[each.key].latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
  }

  desired_capacity = each.value.desired_size
  min_size         = 1
  max_size         = each.value.desired_size * 2

  vpc_zone_identifier = data.terraform_remote_state.nomad.outputs.private_subnets
  # vpc_zone_identifier = data.terraform_remote_state.nomad.outputs.public_subnets

  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestLaunchTemplate"]
  wait_for_capacity_timeout = 0

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances"
  ]
}

check "ami_version_check" {
  assert {
    condition     = alltrue([for p, _ in var.node_pools : data.hcp_packer_artifact.packer[p].external_identifier == aws_launch_template.node_pool[p].image_id])
    error_message = "Launch templates must use the latest available AMIs"
  }
}