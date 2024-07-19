data "tfe_organization" "org" {
  name = var.hcp_terraform_organization
}

resource "tfe_team" "waypoint" {
  name         = "hashiconf-escape-room-waypoint"
  organization = data.tfe_organization.org.name
  visibility   = "organization"
  organization_access {
    read_workspaces   = false
    read_projects     = false
    manage_workspaces = false
  }
}

resource "time_rotating" "waypoint_token" {
  rotation_days = 120
}

resource "tfe_team_token" "waypoint" {
  team_id    = tfe_team.waypoint.id
  expired_at = time_rotating.waypoint_token.rotation_rfc3339
}

resource "hcp_waypoint_tfc_config" "org" {
  token        = tfe_team_token.waypoint.token
  tfc_org_name = tfe_team.waypoint.organization
}

resource "tfe_project" "waypoint" {
  organization = data.tfe_organization.org.name
  name         = "${var.hcp_terraform_project}-apps"
}

resource "tfe_team_project_access" "waypoint" {
  access     = "admin"
  team_id    = tfe_team.waypoint.id
  project_id = tfe_project.waypoint.id
}

data "nomad_node_pools" "all" {}

resource "hcp_waypoint_template" "nomad_app" {
  name    = "nomad-container-application"
  summary = "Deploy a container application to Nomad"

  terraform_cloud_workspace_details = {
    name                 = tfe_project.waypoint.name
    terraform_project_id = tfe_project.waypoint.id
  }

  terraform_no_code_module = {
    source  = "app.terraform.io/hashicorp-team-da-beta/app/nomad"
    version = "0.0.0"
  }

  readme_markdown_template = "IyB0ZXJyYWZvcm0tbm9tYWQtYXBwCgpUaGlzIFRlcnJhZm9ybSBtb2R1bGUgZGVwbG95cyBhbiBhcHBsaWNhdGlvbiB0byBOb21hZCBieQpjcmVhdGluZyBhIE5vbWFkIGpvYi4KCiMjIFJlcXVpcmVtZW50cwoKfCBOYW1lIHwgVmVyc2lvbiB8CnwtLS0tLS18LS0tLS0tLS0tfAp8IDxhIG5hbWU9InJlcXVpcmVtZW50X25vbWFkIj48L2E+IFtub21hZF0oI3JlcXVpcmVtZW50XF9ub21hZCkgfCA+PSAyLjMuMCB8CgojIyBQcm92aWRlcnMKCnwgTmFtZSB8IFZlcnNpb24gfAp8LS0tLS0tfC0tLS0tLS0tLXwKfCA8YSBuYW1lPSJwcm92aWRlcl9ub21hZCI+PC9hPiBbbm9tYWRdKCNwcm92aWRlclxfbm9tYWQpIHwgMi4zLjAgfAoKIyMgTW9kdWxlcwoKTm8gbW9kdWxlcy4KCiMjIFJlc291cmNlcwoKfCBOYW1lIHwgVHlwZSB8CnwtLS0tLS18LS0tLS0tfAp8IFtub21hZF9qb2IuYXBwbGljYXRpb25dKGh0dHBzOi8vcmVnaXN0cnkudGVycmFmb3JtLmlvL3Byb3ZpZGVycy9oYXNoaWNvcnAvbm9tYWQvbGF0ZXN0L2RvY3MvcmVzb3VyY2VzL2pvYikgfCByZXNvdXJjZSB8CnwgW25vbWFkX2pvYl9wYXJzZXIuYXBwbGljYXRpb25dKGh0dHBzOi8vcmVnaXN0cnkudGVycmFmb3JtLmlvL3Byb3ZpZGVycy9oYXNoaWNvcnAvbm9tYWQvbGF0ZXN0L2RvY3MvZGF0YS1zb3VyY2VzL2pvYl9wYXJzZXIpIHwgZGF0YSBzb3VyY2UgfAoKIyMgSW5wdXRzCgp8IE5hbWUgfCBEZXNjcmlwdGlvbiB8IFR5cGUgfCBEZWZhdWx0IHwgUmVxdWlyZWQgfAp8LS0tLS0tfC0tLS0tLS0tLS0tLS18LS0tLS0tfC0tLS0tLS0tLXw6LS0tLS0tLS06fAp8IDxhIG5hbWU9ImlucHV0X2FwcGxpY2F0aW9uX2NvdW50Ij48L2E+IFthcHBsaWNhdGlvblxfY291bnRdKCNpbnB1dFxfYXBwbGljYXRpb25cX2NvdW50KSB8IE51bWJlciBvZiBpbnN0YW5jZXMgZm9yIGFwcGxpY2F0aW9uIHwgYG51bWJlcmAgfCBgMWAgfCBubyB8CnwgPGEgbmFtZT0iaW5wdXRfYXBwbGljYXRpb25fbmFtZSI+PC9hPiBbYXBwbGljYXRpb25cX25hbWVdKCNpbnB1dFxfYXBwbGljYXRpb25cX25hbWUpIHwgTmFtZSBvZiBhcHBsaWNhdGlvbiB8IGBzdHJpbmdgIHwgbi9hIHwgeWVzIHwKfCA8YSBuYW1lPSJpbnB1dF9hcHBsaWNhdGlvbl9wb3J0Ij48L2E+IFthcHBsaWNhdGlvblxfcG9ydF0oI2lucHV0XF9hcHBsaWNhdGlvblxfcG9ydCkgfCBQb3J0IG9mIGFwcGxpY2F0aW9uIHwgYG51bWJlcmAgfCBuL2EgfCB5ZXMgfAp8IDxhIG5hbWU9ImlucHV0X2FyZ3MiPjwvYT4gW2FyZ3NdKCNpbnB1dFxfYXJncykgfCBBcmd1bWVudHMgdG8gcGFzcyB0byBjb21tYW5kIHdoZW4gcnVubmluZyBhcHBsaWNhdGlvbiB8IGBsaXN0KHN0cmluZylgIHwgYG51bGxgIHwgbm8gfAp8IDxhIG5hbWU9ImlucHV0X2NvbW1hbmQiPjwvYT4gW2NvbW1hbmRdKCNpbnB1dFxfY29tbWFuZCkgfCBDb21tYW5kIHRvIHJ1biBhcHBsaWNhdGlvbiB8IGBzdHJpbmdgIHwgYG51bGxgIHwgbm8gfAp8IDxhIG5hbWU9ImlucHV0X2NwdSI+PC9hPiBbY3B1XSgjaW5wdXRcX2NwdSkgfCBDUFUgZm9yIGFwcGxpY2F0aW9uIHwgYG51bWJlcmAgfCBgMjBgIHwgbm8gfAp8IDxhIG5hbWU9ImlucHV0X2RyaXZlciI+PC9hPiBbZHJpdmVyXSgjaW5wdXRcX2RyaXZlcikgfCBOb21hZCBkcml2ZXIgdG8gcnVuIGFwcGxpY2F0aW9uIHwgYHN0cmluZ2AgfCBuL2EgfCB5ZXMgfAp8IDxhIG5hbWU9ImlucHV0X2Vudmlyb25tZW50X3ZhcmlhYmxlcyI+PC9hPiBbZW52aXJvbm1lbnRcX3ZhcmlhYmxlc10oI2lucHV0XF9lbnZpcm9ubWVudFxfdmFyaWFibGVzKSB8IEVudmlyb25tZW50IHZhcmlhYmxlcyBmb3IgYXBwbGljYXRpb24gfCBgbWFwKHN0cmluZylgIHwgYHt9YCB8IG5vIHwKfCA8YSBuYW1lPSJpbnB1dF9pbWFnZSI+PC9hPiBbaW1hZ2VdKCNpbnB1dFxfaW1hZ2UpIHwgQ29udGFpbmVyIGltYWdlIGZvciBhcHBsaWNhdGlvbiB8IGBzdHJpbmdgIHwgbi9hIHwgeWVzIHwKfCA8YSBuYW1lPSJpbnB1dF9tZW1vcnkiPjwvYT4gW21lbW9yeV0oI2lucHV0XF9tZW1vcnkpIHwgTWVtb3J5IGZvciBhcHBsaWNhdGlvbiB8IGBudW1iZXJgIHwgYDEwYCB8IG5vIHwKfCA8YSBuYW1lPSJpbnB1dF9tZXRhZGF0YSI+PC9hPiBbbWV0YWRhdGFdKCNpbnB1dFxfbWV0YWRhdGEpIHwgTWV0YWRhdGEgZm9yIGFwcGxpY2F0aW9uIHwgYG1hcChzdHJpbmcpYCB8IGB7fWAgfCBubyB8CnwgPGEgbmFtZT0iaW5wdXRfbm9kZV9wb29sIj48L2E+IFtub2RlXF9wb29sXSgjaW5wdXRcX25vZGVcX3Bvb2wpIHwgTm9kZSBwb29sIGZvciBhcHBsaWNhdGlvbiB8IGBzdHJpbmdgIHwgYCJkZWZhdWx0ImAgfCBubyB8CnwgPGEgbmFtZT0iaW5wdXRfc2VydmljZV9wcm92aWRlciI+PC9hPiBbc2VydmljZVxfcHJvdmlkZXJdKCNpbnB1dFxfc2VydmljZVxfcHJvdmlkZXIpIHwgTm9tYWQgc2VydmljZSBwcm92aWRlciwgbXVzdCBiZSBjb25zdWwgb3Igbm9tYWQgfCBgc3RyaW5nYCB8IGAiY29uc3VsImAgfCBubyB8CgojIyBPdXRwdXRzCgp8IE5hbWUgfCBEZXNjcmlwdGlvbiB8CnwtLS0tLS18LS0tLS0tLS0tLS0tLXwKfCA8YSBuYW1lPSJvdXRwdXRfam9iX2lkIj48L2E+IFtqb2JcX2lkXSgjb3V0cHV0XF9qb2JcX2lkKSB8IG4vYSB8Cg=="

  variable_options = [
    {
      name          = "application_name"
      variable_type = "string"
    },
    {
      name          = "application_port"
      variable_type = "number"
    },
    {
      name          = "image"
      variable_type = "string"
    },
    {
      name          = "metadata"
      variable_type = "map(string)"
    },
    {
      name          = "node_pool"
      variable_type = "string"
      options       = [for pool in data.nomad_node_pools.all.node_pools : pool.name]
    }
    ,
    {
      name          = "driver"
      variable_type = "string"
      options       = ["docker"]
    },
    {
      name          = "service_provider"
      variable_type = "string"
      options       = ["nomad"]
    }
  ]
}