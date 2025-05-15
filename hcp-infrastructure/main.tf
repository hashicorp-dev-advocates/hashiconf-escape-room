resource "hcp_hvn" "main" {
  hvn_id         = var.name
  cloud_provider = "aws"
  region         = var.aws_region
  cidr_block     = var.hcp_cidr_block
}

resource "hcp_vault_cluster" "main" {
  cluster_id      = var.name
  hvn_id          = hcp_hvn.main.hvn_id
  public_endpoint = var.hcp_vault.public_endpoint
  tier            = var.hcp_vault.tier
}

resource "random_string" "boundary" {
  length  = 4
  upper   = false
  special = false
  numeric = false
}

resource "random_password" "boundary" {
  length      = 16
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 1
}

resource "hcp_boundary_cluster" "main" {
  cluster_id = var.name
  username   = "admin-${random_string.boundary.result}"
  password   = random_password.boundary.result
  tier       = var.hcp_boundary.tier
}