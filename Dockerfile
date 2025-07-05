# Use build arguments for both Atlantis and Packer versions
ARG ATLANTIS_VERSION
ARG PACKER_VERSION


FROM ghcr.io/runatlantis/atlantis:${ATLANTIS_VERSION}

# Install dependencies (Alpine Linux uses apk, not apt-get)
RUN apk update && \
    apk add --no-cache wget unzip curl && \
    rm -rf /var/cache/apk/*

# Install Packer
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/local/bin/ && \
    rm packer_${PACKER_VERSION}_linux_amd64.zip && \
    chmod +x /usr/local/bin/packer

# Verify installation
RUN packer version

# Optional: Install additional tools
# RUN apk add --no-cache ansible jq

USER atlantis