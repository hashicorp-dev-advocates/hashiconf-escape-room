resource "nomad_dynamic_host_volume" "open_webui" {
  name      = "open-webui"
  namespace = "default"

  plugin_id = "mkdir"

  capacity_max = "8.0 GiB"
  capacity_min = "1.0 GiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  node_pool = "gpu"
}

resource "nomad_job" "open_webui" {
  jobspec = <<EOT
job "openwebui" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool   = "gpu"

  group "openwebui" {

    volume "openwebui" {
      type            = "host"
      source          = "${nomad_dynamic_host_volume.open_webui.name}"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    network {
      port "http" {
        to = 8080
      }
    }

    service {
      name     = "openwebui"
      port     = "http"
      tags     = ["http"]
      provider = "nomad"
    }

    task "openwebui" {
      driver = "docker"

      config {
        image   = "ghcr.io/open-webui/open-webui:main"
        ports   = ["http"]
      }

      resources {
        device "nvidia/gpu" {
          count = 1
        }
      }

      volume_mount {
        volume      = "openwebui"
        destination = "/app/backend/data"
      }

      template {
        data = <<EOF
{{- range nomadService "ollama" }}OLLAMA_BASE_URL="http://{{ .Address }}:{{ .Port }}"{{ end -}}
EOF
        destination   = "/app/env.txt"
        env           = true
        change_mode   = "restart"
      }
    }
  }
}
EOT
}
