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

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "ssh" {
  vpc_id = module.vpc.vpc_id
  name   = "allow_ssh"

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "nomad" {
  vpc_id = module.vpc.vpc_id
  name   = "nomad_port"

  ingress {
    from_port = 4646
    protocol  = "tcp"
    to_port   = 4648

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "allow_ssh"
  }
}


resource "aws_security_group" "egress" {
  vpc_id = module.vpc.vpc_id
  name   = "egress"

  ingress {
    from_port = 22
    protocol  = "tcp"
    to_port   = 22

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_eip" "nomad_server" {
  count = 3

  tags = {
    Name = "Nomad Server"
  }
  associate_with_private_ip = "10.0.101.${count.index + 10}"
}

resource "aws_eip_association" "nomad_server" {
  count         = length(aws_instance.nomad_servers.*.id)
  instance_id   = aws_instance.nomad_servers[count.index].id
  allocation_id = aws_eip.nomad_server[count.index].id
}

resource "aws_instance" "nomad_servers" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id     = module.vpc.public_subnets.0
  private_ip = "10.0.101.${count.index + 10}"
  key_name      = aws_key_pair.deployer.key_name


  user_data = templatefile("./servers.sh", {
    NOMAD_SERVER_TAG     = "true"
    NOMAD_SERVER_TAG_KEY = "nomad_server"
    NOMAD_SERVER_COUNT   = 3
    NOMAD_SERVERS_ADDR   = join(",", formatlist("\"%s\"",aws_eip.nomad_server.*.private_ip))
  })

  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.egress.id,
    aws_security_group.nomad.id
  ]

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }

  tags = {
    Name         = "nomad-server-${count.index + 1}"
    nomad_server = true
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.ssh_key
}

resource "aws_instance" "nomad_clients" {
  count                       = 3
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  subnet_id                   = module.vpc.public_subnets.0
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  user_data = templatefile("./clients.sh", {
    NOMAD_SERVERS_ADDR = join(",", formatlist("\"%s\"", aws_instance.nomad_servers.*.private_ip))
  })

  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.egress.id,
    aws_security_group.nomad.id,
  ]

  tags = {
    Name         = "nomad-client-${count.index + 1}"
    nomad_server = false
  }

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }

  depends_on = [
    terracurl_request.nomad_status
  ]

}


resource "aws_instance" "boundary_target" {
  count                       = 1
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  subnet_id                   = module.vpc.public_subnets.0
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  user_data = templatefile("./nomad-client-boundary-target.sh", {
    NOMAD_SERVERS_ADDR = join(",", formatlist("\"%s\"", aws_instance.nomad_servers.*.private_ip))
  })

  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.egress.id,
    aws_security_group.nomad.id,
  ]

  tags = {
    Name         = "boundary-target"
    nomad_server = false
  }

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }

  depends_on = [
    terracurl_request.nomad_status
  ]
}

