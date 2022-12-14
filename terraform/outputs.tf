## Outputs

# SSH
output "ssk_key" {
  value = local_sensitive_file.ssh_key.filename
}

# Nodes
output "nodes_public_ipv4" {
  value = { for node, _ in exoscale_compute_instance.node : node => exoscale_compute_instance.node[node].public_ip_address }
}
output "nodes_public_ipv6" {
  value = { for node, _ in exoscale_compute_instance.node : node => exoscale_compute_instance.node[node].ipv6_address }
}
output "nodes_privnet_ipv4" {
  value = { for node, _ in exoscale_compute_instance.node : node => join(", ", exoscale_compute_instance.node[node].network_interface[*].ip_address) }
}
output "nodes_ssh_public_ipv4" {
  value = { for node, _ in exoscale_compute_instance.node : node => "ssh -i ${local_sensitive_file.ssh_key.filename} ${data.exoscale_compute_template.node_template.username}@${exoscale_compute_instance.node[node].public_ip_address}" }
}
output "nodes_ssh_public_ipv6" {
  value = { for node, _ in exoscale_compute_instance.node : node => "ssh -i ${local_sensitive_file.ssh_key.filename} ${data.exoscale_compute_template.node_template.username}@${exoscale_compute_instance.node[node].ipv6_address}" }
}
output "nodes_ssh_tailscale" {
  value = { for node, _ in exoscale_compute_instance.node : node => "tailscale ssh ${data.exoscale_compute_template.node_template.username}@${exoscale_compute_instance.node[node].name}" }
}
