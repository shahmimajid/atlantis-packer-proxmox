FROM runatlantis/atlantis:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget unzip curl && \
    rm -rf /var/lib/apt/lists/*

# Install Packer
ENV PACKER_VERSION=1.13.1
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/local/bin/ && \
    rm packer_${PACKER_VERSION}_linux_amd64.zip && \
    chmod +x /usr/local/bin/packer

# Verify installation
RUN packer version

# Optional: Install additional tools
# RUN apt-get update && apt-get install -y ansible jq && rm -rf /var/lib/apt/lists/*

USER atlantis