terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.4"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

module "k8s_node" {
  source = "./nodes"
}