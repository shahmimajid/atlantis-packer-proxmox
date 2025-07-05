ARG ATLANTIS_VERSION
ARG PACKER_VERSION

FROM ghcr.io/runatlantis/atlantis:${ATLANTIS_VERSION}

# Switch to root to install dependencies
USER root

RUN apk update && \
    apk add --no-cache wget unzip curl

# Install Packer using build argument
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/local/bin/ && \
    rm packer_${PACKER_VERSION}_linux_amd64.zip && \
    chmod +x /usr/local/bin/packer

# Switch back to atlantis user for security
USER atlantis