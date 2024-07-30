packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = env("AWS_REGION")
}

variable "name" {
  type    = string
  default = "hashistack-ubuntu"
}

variable "owner" {
  type    = string
  default = "platform-team"
}

variable "version" {
  type    = string
  default = env("HCP_PACKER_BUILD_FINGERPRINT")
}

data "amazon-ami" "ubuntu" {
  region = var.aws_region
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "hashistack" {
  ami_name      = "${var.name}-${var.version}"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami    = data.amazon-ami.ubuntu.id
  ssh_username  = "ubuntu"
}

build {
  hcp_packer_registry {
    bucket_name = var.name
    description = "Application VM image. Includes Nomad, Boundary, Consul, Envoy, Vault, and Docker."

    bucket_labels = {
      "owner"         = var.owner
      "os"            = "Ubuntu",
      "base-ami-name" = "{{ .SourceAMIName }}",
      "includes"      = "nomad,consul,boundary,vault,docker,fake-service"
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }

  sources = [
    "source.amazon-ebs.hashistack"
  ]

  provisioner "file" {
    source      = "./scripts/user-data.sh"
    destination = "/tmp/user-data.sh"
  }

  provisioner "file" {
    source      = "./scripts/0-consul.hcl"
    destination = "/tmp/0-consul.hcl"
  }

  provisioner "file" {
    source      = "./scripts/fake.service"
    destination = "/tmp/fake.service"
  }

  provisioner "shell" {
    script = "./scripts/clients.sh"
  }
}
