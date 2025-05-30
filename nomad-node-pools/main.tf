data "hcp_packer_version" "packer" {
  bucket_name  = var.hcp_packer_bucket_name
  channel_name = "latest"
}

data "hcp_packer_artifact" "packer" {
  bucket_name         = var.hcp_packer_bucket_name
  platform            = "aws"
  version_fingerprint = data.hcp_packer_version.packer.fingerprint
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

resource "aws_instance" "nomad_client_llm" {
  ami                         = data.hcp_packer_artifact.packer.external_identifier
  instance_type               = "g6.xlarge"
  subnet_id                   = data.terraform_remote_state.nomad.outputs.private_subnets.1
  key_name                    = "deployer-key"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.nomad.name

  root_block_device {
    delete_on_termination = false
    volume_size           = 100
    volume_type           = "gp3"
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    delete_on_termination = true
    encrypted             = false
    volume_size           = 32
    volume_type           = "gp2"
  }

  vpc_security_group_ids = data.terraform_remote_state.nomad.outputs.security_groups

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  user_data = base64encode(file("./setup.sh"))

  tags = {
    NodePool = "llm",
    Name     = "nomad-client-llm"
    Type     = "gpu"
  }
}

resource "aws_instance" "nomad_client_rag" {
  ami                         = data.hcp_packer_artifact.packer.external_identifier
  instance_type               = "g6.xlarge"
  subnet_id                   = data.terraform_remote_state.nomad.outputs.private_subnets.1
  key_name                    = "deployer-key"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.nomad.name

  root_block_device {
    delete_on_termination = false
    volume_size           = 100
    volume_type           = "gp3"
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    delete_on_termination = true
    encrypted             = false
    volume_size           = 32
    volume_type           = "gp2"
  }

  vpc_security_group_ids = data.terraform_remote_state.nomad.outputs.security_groups

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  user_data = base64encode(file("./setup.sh"))

  tags = {
    NodePool = "tag",
    Name     = "nomad-client-rag"
    Type     = "gpu"
  }
}