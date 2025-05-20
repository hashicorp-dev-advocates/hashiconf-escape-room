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
  default = "ai-ubuntu"
}

variable "owner" {
  type    = string
  default = "platform-team"
}

variable "version" {
  type    = string
  default = env("HCP_PACKER_BUILD_FINGERPRINT")
}

variable "bucket_details" {
  type    = string
  default = ""
}

data "amazon-ami" "ubuntu" {
  region = var.aws_region
  filters = {
    name = "Deep Learning OSS Nvidia Driver AMI GPU PyTorch 2.6.0 (Ubuntu 22.04)*"
  }
  most_recent = true
  owners      = ["898082745236"]
}

source "amazon-ebs" "ai-ubuntu" {
  ami_name      = "${var.name}-${var.version}"
  instance_type = "g6.xlarge"
  region        = var.aws_region
  source_ami    = data.amazon-ami.ubuntu.id
  ssh_username  = "ubuntu"
}

build {
  hcp_packer_registry {
    bucket_name = var.name
    description = "Application VM image. Includes Nomad and Docker."

    bucket_labels = {
      "owner"    = var.owner
      "purpose"  = "gpu"
      "os"       = "Ubuntu",
      "details"  = var.bucket_details,
      "includes" = "nomad,vault,docker"
    }

    build_labels = {
      "build-time"    = timestamp()
      "build-source"  = basename(path.cwd)
    }
  }

  sources = [
    "source.amazon-ebs.ai-ubuntu"
  ]

  provisioner "file" {
    source      = "./scripts/user-data.sh"
    destination = "/tmp/user-data.sh"
  }

  provisioner "shell" {
    script = "./scripts/clients.sh"
  }
}
