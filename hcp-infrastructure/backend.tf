terraform {
  cloud {
    organization = "hashicorp-team-da-beta"
    workspaces {
      name = "hcp-infrastructure"
    }
  }
}