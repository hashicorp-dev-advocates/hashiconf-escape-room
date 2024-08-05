#!/usr/bin/env bash

echo "[$(date +%T)] Generating controller led token for boundary worker"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install boundary-enterprise
# The name to use for the worker
worker_name="${worker_name}"

# The HCP cluster id, cluster id will be set in the system.d job as an environment var
cluster_id="${cluster_id}"

# Username and password used to obtain the worker registration token
username="${username}"
password="${password}"

# The auth id used for authentication
auth_method_id="${auth_method_id}"

# Base url for the HCP cluster
base_url="https://${cluster_id}.boundary.hashicorp.cloud/v1"
auth_url="${base_url}/auth-methods/${auth_method_id}:authenticate"
token_url="${base_url}/workers:create:controller-led"

# Write the config
echo "[$(date +%T)] Writing config to /etc/boundary.d/worker.hcl
cat <<-EOT > /etc/boundary.d/boundary.hcl
  disable_mlock = true
  log_level = "debug"

  hcp_boundary_cluster_id = "${CLUSTER_ID}"

  listener "tcp" {
    address = "0.0.0.0:9202"
    purpose = "proxy"
  }

  worker {
    auth_storage_path="/etc/boundary.d/auth_data"

    controller_generated_activation_token = "${CONTROLLER_GENERATED_ACTIVATION_TOKEN}"

    tags {
      type   = ["public"]
    }
  }
EOT

echo "[$(date +%T)] Generated worker config for worker: ${worker_id}"

systemctl enable boundary
systemctl start boundary