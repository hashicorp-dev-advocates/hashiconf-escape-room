FROM ubuntu:22.04

RUN apt update -y \
    && apt install -y --no-install-recommends gpg wget ca-certificates lsb-release

RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint \
    && /bin/bash -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main"' | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt update -y \
    && apt install -y --no-install-recommends vault boundary terraform consul nomad \
    && rm -rf /var/lib/apt/lists/* \
    && apt clean all
