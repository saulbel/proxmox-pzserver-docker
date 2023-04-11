# Proxmox Provider
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.11"
    }
  }
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_node_name" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type = string
}

variable "proxmox_ssh_key" {
  type = string
}

variable "ansible_ssh_key" {
  type = string
}

provider "proxmox" {
  pm_api_url = var.proxmox_api_url
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure = true
}

#######
# LXC #
#######
##############################################################################
# Ubuntu 22 ct for project zomboid server --> pzserver-1 (no template)       #
##############################################################################
resource "proxmox_lxc" "pzserver-1" {
  hostname = "pzserver-1"
  description = "Ubuntu lxc ct for pz server"
  vmid = "120"
  target_node = var.proxmox_node_name
  ostemplate = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  unprivileged = true

  features {
    nesting = true
  }

  network {
    name = "eth0"
    bridge = "vmbr0"
    ip = "192.168.1.20/24"
    gw = "192.168.1.127"
  }
  
  rootfs {
    storage = "storage"
    size = "50G"
  }

  cores = 2
  memory = 4096
  swap = 0

  ssh_public_keys = <<-EOT
  ${var.proxmox_ssh_key},
  ${var.ansible_ssh_key}
  EOT

  start = true
  
  #provisioner "local-exec" {
  #  command = ""
  #}
}