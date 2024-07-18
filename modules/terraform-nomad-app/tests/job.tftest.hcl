variables {
  application_name = "fake-service"
  image            = "nicholasjackson/fake-service:v0.26.2"
  application_port = 9090
  driver           = "docker"
  service_provider = "nomad"
}

run "run_job" {}

run "check_job" {
  module {
    source = "./tests/setup"
  }

  assert {
    condition     = data.nomad_job.test.status == "running"
    error_message = "Nomad job should have status `running`"
  }
}
