terraform {
  cloud {
    organization = "hashicorp-team-da-beta"
    workspaces {
      name = "payments-infrastructure"
    }
  }
}