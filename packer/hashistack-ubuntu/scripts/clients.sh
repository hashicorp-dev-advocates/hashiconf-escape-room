#! /bin/bash -e

sudo mv /tmp/user-data.sh /opt/user-data.sh

# Install the CNI Plugins
curl -L https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-amd64-v0.9.1.tgz -o /tmp/cni.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf /tmp/cni.tgz

# Install Nomad
sudo apt-get update && \
  sudo apt-get install wget gpg coreutils unzip -y

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install nomad -y

# Create Nomad directory.
sudo mkdir -p /etc/nomad.d

# Install Vault
sudo apt-get install vault -y

# Create Vault directory.
sudo mkdir -p /etc/vault.d

# Install Boundary
sudo apt-get install -y boundary

# Create Boundary directory.
sudo mkdir -p /etc/boundary.d

# Install Consul
sudo apt-get install consul -y

# Create Consul directory.
sudo mkdir -p /etc/consul.d

# Create Consul directories and configuration files
sudo cat > /etc/consul.d/0-consul.hcl <<- EOF
data_dir = "/opt/consul"

client_addr = "0.0.0.0"

bind_addr = "0.0.0.0"

advertise_addr = "{{ GetPrivateIP }}"
EOF

# Install Envoy
sudo apt update
sudo apt install apt-transport-https gnupg2 curl lsb-release
curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | sudo gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg
echo a077cb587a1b622e03aa4bf2f3689de14658a9497a9af2c427bba5f4cc3c4723 /usr/share/keyrings/getenvoy-keyring.gpg | sha256sum --check
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/getenvoy.list
sudo apt update
sudo apt install -y getenvoy-envoy

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Install Java
sudo apt install default-jre -y

# Pull down and install Fake Service
curl -LO https://github.com/nicholasjackson/fake-service/releases/download/v0.26.2/fake_service_linux_amd64.zip
unzip fake_service_linux_amd64.zip
sudo mv fake-service /usr/local/bin
sudo chmod +x /usr/local/bin/fake-service

cat > /etc/systemd/system/fake.service <<- EOF
[Unit]
Description=Fake service systemd file
After=syslog.target network.target

[Service]
ExecStart=/usr/local/bin/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOF