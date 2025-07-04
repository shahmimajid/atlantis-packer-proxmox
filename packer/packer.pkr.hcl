packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variables (can be passed via command line or environment)
variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL"
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox username"
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox password"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
}

variable "proxmox_storage" {
  type        = string
  description = "Proxmox storage pool"
}

variable "template_name" {
  type        = string
  description = "Name for the template"
  default     = "ubuntu-2204-cloudinit"
}

variable "template_id" {
  type        = number
  description = "VM ID for the template"
  default     = 9000
}

# Source configuration
source "proxmox-iso" "ubuntu" {
  # Proxmox connection
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  node                     = var.proxmox_node
  insecure_skip_tls_verify = true

  # VM configuration
  vm_id                = var.template_id
  vm_name              = var.template_name
  template_description = "Ubuntu 22.04 cloud-init template built with Packer"

  # ISO configuration
  iso_url          = "https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
  iso_checksum     = "sha256:45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
  iso_storage_pool = "local"
  unmount_iso      = true

  # Hardware configuration
  cores    = 2
  memory   = 2048
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "20G"
    storage_pool = var.proxmox_storage
    type         = "scsi"
  }

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Cloud-init configuration
  cloud_init              = true
  cloud_init_storage_pool = var.proxmox_storage

  # SSH configuration
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout  = "20m"

  # Boot configuration for automated install
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot      = "c"
  boot_wait = "5s"

  # HTTP server for autoinstall
  http_directory = "http"
}

# Build configuration
build {
  name = "ubuntu-template"
  sources = ["source.proxmox-iso.ubuntu"]

  # Wait for cloud-init to finish
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
    ]
  }

  # Update system and install essential packages
  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install -y cloud-init qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent",
      "sudo apt autoremove -y",
      "sudo apt autoclean"
    ]
  }

  # Clean up for template
  provisioner "shell" {
    inline = [
      "sudo cloud-init clean",
      "sudo rm -rf /var/lib/cloud/instances/*",
      "sudo rm -rf /var/log/cloud-init*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm /var/lib/dbus/machine-id",
      "sudo ln -s /etc/machine-id /var/lib/dbus/machine-id",
      "sudo sync"
    ]
  }
}