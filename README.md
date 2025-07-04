# Atlantis with Packer for Proxmox

This repository provides a streamlined, production-ready setup for running [Atlantis](https://www.runatlantis.io/) with [Packer](https://www.packer.io/) support, enabling GitOps workflows for both Terraform and Packer in Proxmox environments.

---

## Features

- 🐳 **Custom Atlantis Docker image** with Packer pre-installed
- 🔧 **Makefile** for easy, standardized management
- 🔐 **Environment-based configuration** using `.env`
- 📦 **Optional Docker registry push support**
- 🚀 **GitOps workflow** for both Terraform and Packer
- 📝 **MIT License** for maximum openness and adoption

---

## Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo>
cd atlantis-packer
make setup
```

### 2. Configure Environment

Edit the .env file with your actual values:

```bash
vim .env
```

Required variables include:

- Atlantis configuration (GitHub token, webhook secret, etc.)
- Proxmox API credentials
- MinIO/S3 credentials for Terraform state
- SSH public key for VM access

### 3. Start Atlantis

```bash
make setup
```

This will:

- Build the custom Atlantis image with Packer
- Start Atlantis using Docker Compose
- Make Atlantis available at the configured URL

Available Commands

```bash
make help          # Show all available commands
make setup         # Create .env from .env.example
make build         # Build custom Atlantis image
make start         # Build and start Atlantis
make stop          # Stop Atlantis
make restart       # Restart Atlantis
make logs          # Show Atlantis logs
make status        # Show container status
make shell         # Open shell in container
make test          # Test Packer installation
make clean         # Clean up images and containers
make push          # Build and push to registry (optional)
```
---

## Usage

### Terraform Workflows

1. Create/modify Terraform files in the terraform/ directory
2. Open a Pull Request
3. Atlantis will automatically run terraform plan
4. Review the plan and comment atlantis apply to apply changes


### Packer Workflows

1. Create/modify Packer files in the packer/ directory
2. Open a Pull Request
3. Atlantis will run packer validate
4. Comment atlantis apply to build the template


## Directory Structure

├── terraform/          # Terraform configurations
├── packer/             # Packer templates
├── Dockerfile          # Custom Atlantis image
├── docker-compose.yml  # Atlantis service definition
├── atlantis.yaml       # Atlantis workflows
├── Makefile            # Automation commands
├── .env.example        # Example environment variables
├── .env                # Your actual environment (gitignored)
└── README.md           # This file


## Troubleshooting

 - Check Atlantis Logs:
make logs

- Test Packer Installation:
make test

- Access Container Shell:
make shell

- Restart Everything:
make restart


## Security Notes

- Never commit your .env file to version control
- Use strong passwords and tokens
- Regularly rotate credentials
- Keep the Atlantis image updated

## License
This project is licensed under the MIT License.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## References

- Atlantis Documentation
- Packer Documentation
- Proxmox API
