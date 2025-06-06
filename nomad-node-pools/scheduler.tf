locals {
  shutdown_date_for_gpus = "2025-10-01T00:00:00Z"
}

## Reserve GPUs for Ollama. This reservation expires after HashiConf.
resource "aws_ec2_capacity_reservation" "nomad_client_llm" {
  instance_type     = aws_instance.nomad_client_llm.instance_type
  instance_platform = "Linux/UNIX"
  availability_zone = aws_instance.nomad_client_llm.availability_zone
  instance_count    = 1
  ebs_optimized     = true
  end_date          = local.shutdown_date_for_gpus
  end_date_type     = "limited"
}


resource "aws_iam_role" "scheduler" {
  name = "${var.name}-shutdown-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "scheduler" {
  name = "${var.name}-shutdown-policy"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_scheduler_schedule" "instance_shutdown" {
  name = "shutdown-${var.name}-instances"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "at(${replace(local.shutdown_date_for_gpus, "Z", "")})"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      InstanceIds = [
        aws_instance.nomad_client_llm.id,
        aws_instance.nomad_client_rag.id
      ]
    })
  }
}