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
  default = "us-east-2"
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

data "amazon-ami" "ubuntu-focal" {
  region = var.aws_region
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "app-ubuntu" {
  ami_name      = "${var.name}-${var.version}"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami    = data.amazon-ami.ubuntu-focal.id
  ssh_username  = "ubuntu"
  user_data = templatefile("templates/clients.sh", {
    AWS_REGION           = var.aws_region,
    NOMAD_SERVER_TAG_KEY = "nomad_server",
    NOMAD_SERVER_TAG     = "true"
  })
}

build {
  hcp_packer_registry {
    bucket_name = var.name
    description = "Application VM image. Includes Nomad and Docker."

    bucket_labels = {
      "owner"          = var.owner
      "os"             = "Ubuntu",
      "ubuntu-version" = "Focal 20.04",
      "includes"       = "nomad,docker,fake-service"
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }

  sources = [
    "source.amazon-ebs.app-ubuntu"
  ]
}
