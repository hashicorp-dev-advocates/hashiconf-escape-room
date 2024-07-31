output "hcp_packer_artifacts" {
  value       = { for a in data.hcp_packer_artifact.packer : a.bucket_name => a.external_identifier... }
  description = "AMI IDs used with HCP Packer buckets for images"
}