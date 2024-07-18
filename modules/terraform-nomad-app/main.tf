data "nomad_job_parser" "application" {
  hcl = templatefile("${path.module}/templates/jobspec.hcl", {
    application_name      = var.application_name
    application_port      = var.application_port
    application_count     = var.application_count
    node_pool             = var.node_pool
    driver                = var.driver
    command               = var.command
    args                  = var.args
    environment_variables = var.environment_variables
    cpu                   = var.cpu
    memory                = var.memory
    image                 = var.image
    service_provider      = var.service_provider
    metadata              = var.metadata
  })
  canonicalize = false
}

resource "nomad_job" "application" {
  jobspec = data.nomad_job_parser.application.json
  json    = true
}