## Data sources

# Localhost
data "external" "localhost_ipv4" {
  program = ["wget", "-q4O-", "https://api64.ipify.org?format=json"]
}

# Nodes
data "exoscale_compute_template" "node_template" {
  zone = var.exoscale_zone
  name = var.exoscale_instance_template
}
