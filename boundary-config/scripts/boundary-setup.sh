#!/usr/bin/env bash

echo "[$(date +%T)] Generating controller led token for boundary worker"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install boundary-enterprise

mkdir "/boundary/auth_data"
# Write the config
cat <<EOT > /etc/boundary.d/boundary.hcl
  disable_mlock = true
  log_level = "debug"

  hcp_boundary_cluster_id = "${CLUSTER_ID}"

  listener "tcp" {
    address = "0.0.0.0:9202"
    purpose = "proxy"
  }

  worker {
    auth_storage_path="/boundary/auth_data"

    controller_generated_activation_token = "${CONTROLLER_GENERATED_ACTIVATION_TOKEN}"

    tags {
      type   = ["public"]
    }
  }
EOT


systemctl enable boundary
systemctl start boundary