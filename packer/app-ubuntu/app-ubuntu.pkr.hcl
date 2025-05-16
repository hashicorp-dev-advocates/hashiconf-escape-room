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
  default = "app-ubuntu"
}

variable "owner" {
  type    = string
  default = "platform-team"
}

variable "version" {
  type    = string
  default = env("HCP_PACKER_BUILD_FINGERPRINT")
}

variable "build_details" {
  type    = string
  default = env("HCP_PACKER_BUILD_DETAILS")
}

variable "bucket_details" {
  type    = string
  default = ""
}

data "amazon-ami" "ubuntu" {
  region = var.aws_region
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "app-ubuntu" {
  ami_name      = "${var.name}-${var.version}"
  instance_type = "t2.micro"
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
      "os"       = "Ubuntu",
      "details"  = var.bucket_details,
      "includes" = "nomad,vault,docker,fake-service"
    }

    build_labels = {
      "build-time"    = timestamp()
      "build-source"  = basename(path.cwd)
      "build-details" = var.build_details
    }
  }

  sources = [
    "source.amazon-ebs.app-ubuntu"
  ]

  provisioner "file" {
    source      = "./scripts/user-data.sh"
    destination = "/tmp/user-data.sh"
  }

  provisioner "shell" {
    script = "./scripts/clients.sh"
  }
}
