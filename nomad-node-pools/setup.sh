#!/bin/bash

# Add EBS volume for Nomad host volumes
mkfs -t xfs /dev/nvme1n1
mkdir -p /etc/nomad.d/data/host_volumes
mount /dev/nvme1n1 /etc/nomad.d/data/host_volumes

chgrp nomad /etc/nomad.d/data/host_volumes
chmod g+rwx /etc/nomad.d/data/host_volumes

# Add EBS volume for Docker
mkfs -t xfs /dev/nvme2n1
mkdir -p /var/lib/docker
mount /dev/nvme2n1 /var/lib/docker

chgrp docker /var/lib/docker
chmod g+rwx /var/lib/docker

systemctl enable docker
systemctl restart docker

bash /opt/user-data.sh