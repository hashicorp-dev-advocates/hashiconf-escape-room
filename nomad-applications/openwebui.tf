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
  purge_on_destroy = true
  jobspec          = <<EOT
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
        image              = "ghcr.io/open-webui/open-webui:main"
        ports              = ["http"]
        extra_hosts        = ["host.docker.internal:host-gateway"]
      }

      resources {
        cores  = 2
        memory = 12000
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
        ENABLE_OPENAI_API        = "False"
        CHUNK_SIZE               = "2048"
        CHUNK_OVERLAP            = "1024"
        RAG_TOP_K                = "15"
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
