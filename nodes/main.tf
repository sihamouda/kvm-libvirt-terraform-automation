terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.4"
    }
  }
}

resource "libvirt_pool" "k8s_pool" {
  name = "k8s_pool"
  type = "dir"
  path = "/home/anis/k8s_pool"
}

resource "libvirt_volume" "k8s_node_qcow2" {
  name = "k8s_node"
  pool   = libvirt_pool.k8s_pool.name
  source = var.k8s_node_qcow2
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool   = libvirt_pool.k8s_pool.name
}

resource "libvirt_domain" "k8s_node" {
  name   = "k8s_node"
  memory = "5120"
  vcpu   = 4

	cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "${libvirt_volume.k8s_node_qcow2.id}"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
    source_path = "/dev/pts/0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

}

