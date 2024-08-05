terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.57.1"
    }
  }
}

provider "tfe" {}


variable "tfc_organization" {
  type        = string
  description = "TFC organization"
  default     = "hashicorp-team-da-beta"
}

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
  organization = var.tfc_organization
}

data "tfe_workspace" "attach" {
  for_each     = var.workspaces
  name         = each.value
  organization = var.tfc_organization
}

resource "tfe_workspace_variable_set" "clues" {
  for_each        = data.tfe_workspace.attach
  workspace_id    = each.value.id
  variable_set_id = tfe_variable_set.clues.id
}

data "tfe_project" "attach" {
  name         = "hashiconf-escape-room-apps"
  organization = var.tfc_organization
}

resource "tfe_project_variable_set" "apps" {
  project_id      = data.tfe_project.attach.id
  variable_set_id = tfe_variable_set.clues.id
}