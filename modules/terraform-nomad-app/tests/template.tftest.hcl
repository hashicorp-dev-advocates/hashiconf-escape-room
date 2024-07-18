variables {
  application_name = "test-app"
  environment_variables = {
    "LISTEN_ADDR"   = "0.0.0.0:19090"
    "UPSTREAM_URIS" = "10.0.0.2:8080"
  }
  image            = "nicholasjackson/fake-service:v0.26.2"
  application_port = 9090
  metadata = {
    "test" = "123"
  }
}

run "docker_job_spec" {
  variables {
    driver  = "docker"
    command = "sleep"
    args    = ["30"]
  }

  command = plan

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).Name == "test-app"
    error_message = "Job spec name did not match `test-app`"
  }

  assert {
    condition     = length(jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Env) == 2
    error_message = "Job spec environment variables should have 2"
  }

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).Meta == {"test" = "123"}
    error_message = "Job spec metadata should have 1"
  }

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config.image == "nicholasjackson/fake-service:v0.26.2"
    error_message = "Job spec image should be fake-service"
  }

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config.command == "sleep"
    error_message = "Job spec command should be sleep"
  }

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config.args == ["30"]
    error_message = "Job spec args should be `[\"30\"]`"
  }
}

run "exec_job_spec" {
  variables {
    driver = "exec"
  }

  command = plan

  assert {
    condition     = jsondecode(nomad_job.application.jobspec).Name == "test-app"
    error_message = "Job spec name did not match `test-app`"
  }

  assert {
    condition     = length(jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Env) == 2
    error_message = "Job spec environment variables should have 2"
  }

  assert {
    condition     = !contains(keys(jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config), ["image"])
    error_message = "Job spec image should be null"
  }

  assert {
    condition     = !contains(keys(jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config), ["command"])
    error_message = "Job spec command should be null"
  }

  assert {
    condition     = !contains(keys(jsondecode(nomad_job.application.jobspec).TaskGroups.0.Tasks.0.Config), ["args"])
    error_message = "Job spec args should be null"
  }
}
