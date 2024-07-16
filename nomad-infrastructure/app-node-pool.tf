data "hcp_packer_version" "app_ubuntu" {
  bucket_name  = var.hcp_packer_bucket_name
  channel_name = "latest"
}

data "hcp_packer_artifact" "app_ubuntu" {
  bucket_name         = var.hcp_packer_bucket_name
  platform            = "aws"
  version_fingerprint = data.hcp_packer_version.app_ubuntu.fingerprint
  region              = var.aws_region
}

resource "aws_launch_template" "app_node_pool" {
  name_prefix   = var.name
  image_id      = data.hcp_packer_artifact.app_ubuntu.external_identifier
  instance_type = "t3.medium"
  key_name      = aws_key_pair.deployer.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.nomad.name
  }

  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.subnet_allow.id,
    aws_security_group.nomad.id,
    aws_security_group.egress.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = merge({
      NodePool = var.hcp_packer_bucket_name
    }, var.tags)
  }
}

resource "aws_autoscaling_group" "app_node_pool" {
  name_prefix = var.name

  launch_template {
    id      = aws_launch_template.app_node_pool.id
    version = aws_launch_template.app_node_pool.latest_version
  }

  desired_capacity = 3
  min_size         = 1
  max_size         = 3

  vpc_zone_identifier = module.vpc.private_subnets

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

  depends_on = [
    terracurl_request.nomad_status
  ]
}