resource "nomad_dynamic_host_volume" "open_webui" {
  name      = "open-webui"
  namespace = "default"

  plugin_id = "mkdir"

  capacity_max = "12.0 GiB"
  capacity_min = "8.0 GiB"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  node_pool = "rag"
}

resource "nomad_job" "open_webui" {
  jobspec = <<EOT
job "openwebui" {
  datacenters = ["dc1"]
  type        = "service"
  node_pool   = "rag"

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
        image   = "ghcr.io/open-webui/open-webui:cuda"
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

      env {
        ENABLE_USER_WEBHOOKS     = "False"
        SHOW_ADMIN_DETAILS       = "False"
        ENABLE_CODE_EXECUTION    = "False"
        ENABLE_CODE_INTERPRETER  = "False"
        ENABLE_MESSAGE_RATING    = "False"
        ENABLE_COMMUNITY_SHARING = "False"
        SAFE_MODE                = "True"
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
