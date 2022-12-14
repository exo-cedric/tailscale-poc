locals {
  ## Test parameters

  # Unique test ID/name
  test_name = "${var.test_name}-${random_string.test_id.result}"


  ## Exoscale

  # Private network
  privnet_network  = "10.42.168.0"
  privnet_netmask  = "255.255.255.0"
  privnet_netcidr  = "24"
  privnet_start_ip = "10.42.168.200"
  privnet_end_ip   = "10.42.168.249"
  privnet_static = {
    "gateway"  = "10.42.168.1"
    "internal" = "10.42.168.11"
  }
}
