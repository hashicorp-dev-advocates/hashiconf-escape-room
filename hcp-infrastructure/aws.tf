locals {
  hcp_terraform_url  = "app.terraform.io"
  github_actions_url = "token.actions.githubusercontent.com"
}

data "tls_certificate" "hcp_terraform" {
  url = "https://${local.hcp_terraform_url}"
}

resource "aws_iam_openid_connect_provider" "hcp_terraform" {
  url             = data.tls_certificate.hcp_terraform.url
  client_id_list  = [var.hcp_terraform_aws_audience]
  thumbprint_list = [data.tls_certificate.hcp_terraform.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "hcp_terraform" {
  name = "${var.name}-hcp-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.hcp_terraform.arn}"
        }
        Condition = {
          StringEquals = {
            "${local.hcp_terraform_url}:aud" = "${one(aws_iam_openid_connect_provider.hcp_terraform.client_id_list)}"
          }
          StringLike = {
            "${local.hcp_terraform_url}:sub" = "organization:${var.hcp_terraform_organization}:project:${var.name}:workspace:*:run_phase:*"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "hcp_terraform" {
  name        = "${var.name}-hcp-terraform"
  description = "HCP Terraform policies"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "ec2:*",
        "autoscaling:*",
        "elasticloadbalancing:*",
        "iam:*Role*",
        "iam:*Policy*",
        "iam:*Profile*",
        "rds:*",
        "ecr:*",
        "apprunner:*",
        "secretsmanager:*",
      ]
      Effect   = "Allow"
      Resource = "*"
      }, {
      Action = [
        "iam:CreateServiceLinkedRole",
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:iam::*:role/aws-service-role/apprunner.amazonaws.com/AWSServiceRoleForAppRunner",
        "arn:aws:iam::*:role/aws-service-role/networking.apprunner.amazonaws.com/AWSServiceRoleForAppRunnerNetworking"
      ],
      Condition = {
        StringLike = {
          "iam:AWSServiceName" = [
            "apprunner.amazonaws.com",
            "networking.apprunner.amazonaws.com"
          ]
        }
      }
      }, {
      Action = [
        "iam:PassRole",
      ]
      Effect   = "Allow"
      Resource = "*",
      Condition = {
        StringLike = {
          "iam:PassedToService" = "apprunner.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "hcp_terraform" {
  role       = aws_iam_role.hcp_terraform.name
  policy_arn = aws_iam_policy.hcp_terraform.arn
}

data "tls_certificate" "github_actions" {
  url = "https://${local.github_actions_url}"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = data.tls_certificate.github_actions.url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "github_actions" {
  name = "${var.name}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.github_actions.arn}"
        }
        Condition = {
          StringEquals = {
            "${local.github_actions_url}:sub" = [for repository in var.repositories : "repo:${var.github_user}/${repository}:ref:refs/heads/main"]
            "${local.github_actions_url}:aud" = "sts.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "github_actions" {
  name = "${var.name}-github-actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CopyImage",
          "ec2:CreateImage",
          "ec2:CreateKeyPair",
          "ec2:CreateSecurityGroup",
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteKeyPair",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteSnapshot",
          "ec2:DeleteVolume",
          "ec2:DeregisterImage",
          "ec2:DescribeImageAttribute",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeRegions",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSnapshots",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DetachVolume",
          "ec2:GetPasswordData",
          "ec2:ModifyImageAttribute",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifySnapshotAttribute",
          "ec2:RegisterImage",
          "ec2:RunInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

resource "aws_iam_policy" "github_actions_ecr" {
  name = "${var.name}-github-actions-ecr"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}

resource "aws_iam_role" "boundary_session_recordings" {
  name = "${var.name}-boundary-session-recordings"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "boundary_session_recordings" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [provider::aws::arn_build("aws", "s3", "", "", var.bucket_name)]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:DeleteObject",
    ]
    resources = [provider::aws::arn_build("aws", "s3", "", "", "${var.bucket_name}/*")]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [provider::aws::arn_build("aws", "kms", var.aws_region, data.aws_caller_identity.current.account_id, var.bucket_name)]
  }
}

resource "aws_iam_policy" "boundary_session_recordings" {
  name_prefix = "${var.name}-boundary-bucket-"
  description = "Policy for Boundary session recording"
  policy      = data.aws_iam_policy_document.boundary_session_recordings.json
}

resource "aws_iam_role_policy_attachment" "boundary_session_recordings" {
  role       = aws_iam_role.boundary_session_recordings.name
  policy_arn = aws_iam_policy.boundary_session_recordings.arn
}