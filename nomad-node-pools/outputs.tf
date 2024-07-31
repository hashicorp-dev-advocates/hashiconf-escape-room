output "hcp_packer_artifacts" {
  value = {
    bucket_names         = data.hcp_packer_artifact.packer.*.bucket_name
    external_identifiers = data.hcp_packer_artifact.packer.*.external_identifier
  }
}