terraform {
  cloud {
    organization = "hashicorp-team-da-beta"
    workspaces {
      name = "nomad-applications"
    }
  }
}