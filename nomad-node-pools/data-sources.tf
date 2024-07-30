data "terraform_remote_state" "nomad" {
  backend = "remote"

  config = {
    organization = "hashicorp-team-da-beta"

    workspaces = {
      name = "nomad-infrastructure"
    }
  }
}