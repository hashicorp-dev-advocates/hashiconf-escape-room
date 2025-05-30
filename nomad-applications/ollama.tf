resource "nomad_dynamic_host_volume" "ollama" {
  name      = "ollama"
  namespace = "default"

  plugin_id = "mkdir"

  capacity_max = "12.0 GiB"
  capacity_min = "8.0 GiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  node_pool = "llm"
}

resource "nomad_job" "ollama" {
  jobspec = <<EOT
job "ollama" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool   = "llm"

  group "ollama" {

    volume "ollama" {
      type            = "host"
      source          = "${nomad_dynamic_host_volume.ollama.name}"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    network {
      port "http" {
        static = 11434
      }
    }

    service {
      name     = "ollama"
      port     = "http"
      tags     = ["http"]
      provider = "nomad"
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

      env {
        NVIDIA_VISIBLE_DEVICES     = "all"
        NVIDIA_DRIVER_CAPABILITIES = "compute,utility"
        CUDA_VISIBLE_DEVICES       = "0"
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
