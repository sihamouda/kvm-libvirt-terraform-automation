output "k8s_node_ip" {
    value = libvirt_domain.k8s_node_1.network_interface
}