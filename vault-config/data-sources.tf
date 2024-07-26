data "terraform_remote_state" "hcp" {
  backend = "remote"

  config = {
    organization = "hashicorp-team-da-beta"

    workspaces = {
      name = "hcp-infrastructure"
    }
  }
}