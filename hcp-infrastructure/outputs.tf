output "hvn" {
  value = {
    id         = hcp_hvn.main.hvn_id
    cidr_block = hcp_hvn.main.cidr_block
  }
}

output "vault" {
  value = {
    cluster_id       = hcp_vault_cluster.main.cluster_id
    public_endpoint  = hcp_vault_cluster.main.vault_public_endpoint_url
    private_endpoint = hcp_vault_cluster.main.vault_private_endpoint_url
    namespace        = hcp_vault_cluster.main.namespace
  }
}

locals {
  without_https = replace(hcp_boundary_cluster.main.cluster_url, "https://", "")
  final_string  = replace(local.without_https, ".boundary.hashicorp.cloud", "")
}

output "boundary" {
  value = {
    cluster_id      = local.final_string
    public_endpoint = hcp_boundary_cluster.main.cluster_url
    username        = hcp_boundary_cluster.main.username
  }
}

output "boundary_password" {
  value     = hcp_boundary_cluster.main.password
  sensitive = true
}

output "boundary_session_recording_iam" {
  value = {
    role      = aws_iam_role.boundary_session_recordings.arn
    role_name = aws_iam_role.boundary_session_recordings.name
    policy    = aws_iam_policy.boundary_session_recordings.arn
  }
}