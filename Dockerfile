# Define build arguments before FROM (for FROM instruction)
ARG ATLANTIS_VERSION
ARG PACKER_VERSION

FROM ghcr.io/runatlantis/atlantis:${ATLANTIS_VERSION}

# Re-declare ARG after FROM to make it available for RUN instructions
ARG PACKER_VERSION

# Switch to root to install dependencies
USER root

# Install dependencies (Alpine Linux syntax)
RUN apk update && \
    apk add --no-cache wget unzip curl

# Install Packer using build argument (now PACKER_VERSION is available)
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/local/bin/ && \
    rm packer_${PACKER_VERSION}_linux_amd64.zip && \
    chmod +x /usr/local/bin/packer

# Verify installations
RUN atlantis version && packer version

# Switch back to atlantis user for security
USER atlantis