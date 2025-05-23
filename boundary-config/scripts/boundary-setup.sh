#!/usr/bin/env bash

echo "[$(date +%T)] Generating controller led token for boundary worker"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install boundary-enterprise

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/public-ipv4")

sudo mkdir -p "/boundary/auth_data"
sudo chmod -R 777 /boundary/auth_data

# Write the config
cat <<EOT > /etc/boundary.d/boundary.hcl
disable_mlock = true

hcp_boundary_cluster_id = "${CLUSTER_ID}"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  public_addr = "$${PUBLIC_IPV4}"

  auth_storage_path="/boundary/auth_data"

  controller_generated_activation_token = "${CONTROLLER_GENERATED_ACTIVATION_TOKEN}"

  tags {
    type    = ["public"]
    purpose = "${PURPOSE}"
  }
}
EOT

systemctl enable boundary
systemctl start boundary