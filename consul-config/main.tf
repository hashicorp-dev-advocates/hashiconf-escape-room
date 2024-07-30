resource "hcp_consul_cluster_root_token" "root" {
  cluster_id = data.terraform_remote_state.hcp.outputs.consul.cluster_id
}