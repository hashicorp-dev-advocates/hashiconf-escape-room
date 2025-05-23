resource "nomad_dynamic_host_volume" "ollama" {
  name      = "ollama"
  namespace = "default"

  plugin_id = "mkdir"

  capacity_max = "12 GiB"
  capacity_min = "1.0 GiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  constraint {
    attribute = "$${driver.docker.runtimes}"
    value     = "io.containerd.runc.v2,nvidia,runc"
  }

  node_pool = "gpu"
}

resource "nomad_job" "ollama" {
  jobspec = <<EOT
job "ollama" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool   = "gpu"

  group "ollama" {

    volume "ollama" {
      type            = "host"
      source          = "${nomad_dynamic_host_volume.ollama.name}"
      access_mode     = "single-node-single-writer"
      attachment_mode = "file-system"
    }

    network {
      port "http" {
        to = 11434
      }
    }

    service {
      name = "ollama"
      port = "http"
      tags = ["http"]
    }

    task "ollama" {
      driver = "docker"

      config {
        image   = "ollama/ollama"
        ports   = ["http"]
      }

      resources {
        device "nvidia/gpu" {
          count = 1
        }
      }

      volume_mount {
        volume      = "ollama"
        destination = "/root/.ollama"
      }

      action "pull-model" {
        command = "ollama"
        args = [
          "pull",
          "${var.model}"
        ]
      }
    }
  }
}
EOT
}
