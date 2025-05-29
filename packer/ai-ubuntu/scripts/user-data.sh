#! /bin/bash -e

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 600")
NODE_POOL=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/NodePool)
AWS_REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)

# Add EBS volume for Docker
mkfs -t xfs /dev/nvme1n1
mkdir -p /var/lib/docker
mount /dev/nvme1n1 /var/lib/docker

chgrp docker /var/lib/docker
chmod g+rwx /var/lib/docker

systemctl enable docker
systemctl restart docker

# Nomad configuration files
cat <<EOF > /etc/nomad.d/nomad.hcl
log_level = "INFO"
data_dir = "/etc/nomad.d/data"
plugin_dir = "/opt/nomad/plugins"

client {
  enabled    = true

  server_join {
    retry_join = ["provider=aws region=$AWS_REGION tag_key=nomad_server tag_value=true"]
  }

  node_pool = "$NODE_POOL"
}

plugin "docker" {
  config {
    allow_privileged = false
    allow_caps = [
      "audit_write", "chown", "dac_override", "fowner", "fsetid", "kill", "mknod",
      "net_bind_service", "setfcap", "setgid", "setpcap", "setuid", "sys_chroot",
      "ipc_lock"
    ]
  }
}

plugin "nomad-device-nvidia" {
  config {
    enabled            = true
    fingerprint_period = "1m"
  }
}

autopilot {
    cleanup_dead_servers      = true
    last_contact_threshold    = "200ms"
    max_trailing_logs         = 250
    server_stabilization_time = "10s"
    enable_redundancy_zones   = false
    disable_upgrade_migration = false
    enable_custom_upgrades    = false
}
EOF

cat <<EOF > /etc/nomad.d/acl.hcl
acl = {
  enabled = true
}
EOF

cat <<EOF > /home/ubuntu/update.sh
## TODO: Update this file when you build a new AMI.
EOF

systemctl enable nomad
systemctl restart nomad