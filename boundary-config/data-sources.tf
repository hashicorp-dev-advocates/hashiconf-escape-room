data "terraform_remote_state" "hcp" {
  backend = "remote"

  config = {
    organization = "hashicorp-team-da-beta"

    workspaces = {
      name = "hcp-infrastructure"
    }
  }
}

data "terraform_remote_state" "nomad" {
  backend = "remote"

  config = {
    organization = "hashicorp-team-da-beta"

    workspaces = {
      name = "nomad-infrastructure"
    }
  }
}

data "terraform_remote_state" "consul" {
  backend = "remote"

  config = {
    organization = "hashicorp-team-da-beta"

    workspaces = {
      name = "consul-config"
    }
  }
}


data "aws_subnet" "private" {
  cidr_block = "10.0.1.0/24"
}

data "aws_subnet" "public" {
  cidr_block = "10.0.101.0/24"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_key_pair" "deployer" {
  key_name = "deployer-key"
}

