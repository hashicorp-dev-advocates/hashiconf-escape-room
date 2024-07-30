resource "hcp_consul_cluster_root_token" "root" {
  cluster_id = data.terraform_remote_state.hcp.outputs.consul.cluster_id
}

resource "consul_node" "nodes" {
  for_each = {
    for svc in var.services :
    svc.service_name => svc
  }

  address = each.value["node_address"]
  name    = each.value["node_name"]
}

resource "consul_service" "services" {

  for_each = {
    for svc in var.services :
        svc.service_name => svc
  }

  name = each.value["service_name"]
  node = each.value["node_name"]
  meta =each.value["meta"]
  port = each.value["port"]
  tags = each.value["tags"]

  depends_on = [
    consul_node.nodes
  ]
}