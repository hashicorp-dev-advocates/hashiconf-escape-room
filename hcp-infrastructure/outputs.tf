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

output "consul" {
  value = {
    cluster_id       = hcp_consul_cluster.main.cluster_id
    public_endpoint  = hcp_consul_cluster.main.consul_public_endpoint_url
    private_endpoint = hcp_consul_cluster.main.consul_private_endpoint_url
    datacenter       = hcp_consul_cluster.main.datacenter
  }
}

output "boundary" {
  value = {
    cluster_id      = hcp_boundary_cluster.main.cluster_id
    public_endpoint = hcp_boundary_cluster.main.cluster_url
    username        = hcp_boundary_cluster.main.username
  }
}

output "boundary_password" {
  value     = hcp_boundary_cluster.main.password
  sensitive = true
}