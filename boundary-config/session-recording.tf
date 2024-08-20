resource "aws_s3_bucket" "hashiconf" {
  bucket = "hashiconf-recordings"

}

resource "aws_s3_access_point" "backend_recordings" {
  provider = "aws.boundary"
  bucket   = aws_s3_bucket.hashiconf.bucket
  name     = aws_s3_bucket.hashiconf.bucket

  vpc_configuration {
    vpc_id = data.terraform_remote_state.nomad.outputs.vpc_id
  }
}

resource "boundary_storage_bucket" "backend_recordings" {
  name        = "hashiconf_escape_room"
  description = "All the recordings for HashiConf Escape Room"
  scope_id    = boundary_scope.hashiconf_escape_room_org.id
  plugin_name = "aws"
  bucket_name = aws_s3_bucket.hashiconf.bucket
  attributes_json = jsonencode({
    "region"                      = var.aws_region
    "disable_credential_rotation" = true
    "role_arn" = data.terraform_remote_state.hcp.outputs.boundary_session_recording_iam
  })

  secrets_json = jsonencode({})

  worker_filter = <<EOF
"/name" == "main"
EOF


  depends_on = [
    aws_s3_access_point.backend_recordings,
    aws_instance.boundary_worker_public
  ]
}