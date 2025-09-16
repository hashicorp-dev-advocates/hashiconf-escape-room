#!/bin/bash
set -euxo pipefail

# Detect default user + admin group (Ubuntu vs Amazon Linux)
DEFAULT_USER=""
ADMIN_GROUP=""
if id ubuntu &>/dev/null; then
  DEFAULT_USER="ubuntu"
  ADMIN_GROUP="sudo"
elif id ec2-user &>/dev/null; then
  DEFAULT_USER="ec2-user"
  ADMIN_GROUP="wheel"
else
  # Fallback to whoever exists
  DEFAULT_USER="$(getent passwd 1000 | cut -d: -f1 || true)"
  ADMIN_GROUP="sudo"
fi

mkdir -p /patchify

# Write the log file
cat > /patchify/logs.txt <<'EOD'
Date: 2025-09-16
Patch Version: 10.2.7
Codename: alcatraz

---
Items:
- Item: Aether Shard
  UUID: 1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d
- Item: Chrono Key
  UUID: 8b7a6c5d-4e3f-2d1c-0b9a-8f7e6d5c4b3a
- Item: Voidstone Fragment
  UUID: f1e2d3c4-b5a6-9b8c-7d6e-5f4a3b2c1d0e
- Item: Echo Bloom
  UUID: c9d8e7f6-a5b4-3c2d-1e0f-9a8b7c6d5e4f
EOD

# Permissions/ownership
chown root:${DEFAULT_USER:-root} /patchify/logs.txt
chmod 644 /patchify/logs.txt

# Optionally drop the default user's admin rights (if both exist)
if [ -n "$DEFAULT_USER" ] && getent group "$ADMIN_GROUP" >/dev/null; then
  # Ubuntu: deluser ubuntu sudo
  # Amazon Linux: gpasswd -d ec2-user wheel
  if command -v deluser >/dev/null 2>&1; then
    deluser "$DEFAULT_USER" "$ADMIN_GROUP" || true
  elif command -v gpasswd >/dev/null 2>&1; then
    gpasswd -d "$DEFAULT_USER" "$ADMIN_GROUP" || true
  fi
fi
