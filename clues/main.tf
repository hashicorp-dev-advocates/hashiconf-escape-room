terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.57.1"
    }
  }
}

provider "tfe" {}

variable "workspaces" {
  type        = set(string)
  description = "Set of workspaces that use clues"
  default     = ["applications"]
}

variable "application_and_clues" {
  type = map(object({
    waypoint_clues = string
    nomad_clues    = string
    node_pool      = string
    port           = number

  }))
  description = "Applications and their clues"
}

resource "tfe_variable" "clues" {
  key             = "applications"
  value           = jsonencode(var.application_and_clues)
  category        = "terraform"
  hcl             = true
  description     = "A list of applications and codes"
  variable_set_id = tfe_variable_set.clues.id
}

resource "tfe_variable_set" "clues" {
  name         = "hashiconf-escape-room-clues"
  description  = "Clues for HashiConf escape room"
  organization = "hashicorp-team-da-beta"
}

data "tfe_workspace" "attach" {
  for_each     = var.workspaces
  name         = each.value
  organization = "hashicorp-team-da-beta"
}

resource "tfe_workspace_variable_set" "clues" {
  for_each        = data.tfe_workspace.attach
  workspace_id    = each.value.id
  variable_set_id = tfe_variable_set.clues.id
}