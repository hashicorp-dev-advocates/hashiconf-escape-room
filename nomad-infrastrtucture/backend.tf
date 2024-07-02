terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "hashicorp-team-da-beta"

    workspaces {
      name = "nomad-infrastructure"
    }
  }
}