## Remote infrastructure

# Private network
resource "exoscale_private_network" "privnet" {
  # REF: https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/private_network
  zone = var.exoscale_zone
  name = "${local.test_name}-privnet"

  netmask  = local.privnet_netmask
  start_ip = local.privnet_start_ip
  end_ip   = local.privnet_end_ip
}

# Nodes
resource "exoscale_anti_affinity_group" "aag" {
  # REF: https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/anti_affinity_group
  name = local.test_name
}

resource "exoscale_security_group" "sg" {
  # REF: https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/security_group
  name = local.test_name
}

resource "exoscale_security_group_rule" "sg_rule" {
  # REF: https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/security_group_rule
  for_each = {
    "ssh-external"   = { protocol = "TCP", port = 22, cidr = "${data.external.localhost_ipv4.result["ip"]}/32" }
    "ssh-internal"   = { protocol = "TCP", port = 22, sg = exoscale_security_group.sg.id }
    "ping-internal"  = { protocol = "ICMP", icmp_type = 8, icmp_code = 0, sg = exoscale_security_group.sg.id }
    "ping6-internal" = { protocol = "ICMPv6", icmp_type = 128, icmp_code = 0, sg = exoscale_security_group.sg.id }
  }

  description            = "${local.test_name}-${each.key}"
  security_group_id      = exoscale_security_group.sg.id
  protocol               = each.value["protocol"]
  type                   = "INGRESS"
  start_port             = try(split("-", each.value.port)[0], each.value.port, null)
  end_port               = try(split("-", each.value.port)[1], each.value.port, null)
  icmp_type              = try(each.value.icmp_type, null)
  icmp_code              = try(each.value.icmp_code, null)
  cidr                   = try(each.value.cidr, null)
  user_security_group_id = try(each.value.sg, null)
}

resource "exoscale_compute_instance" "node" {
  # REF: https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/compute_instance
  for_each = toset(["gateway", "internal"])

  zone = var.exoscale_zone
  name = "${local.test_name}-${each.key}"

  type        = "standard.small"
  template_id = data.exoscale_compute_template.node_template.id
  disk_size   = 10
  ipv6        = true

  ssh_key   = exoscale_ssh_key.ssh_key.name
  user_data = data.cloudinit_config.user_data[each.key].rendered

  security_group_ids = [exoscale_security_group.sg.id]

  network_interface {
    network_id = exoscale_private_network.privnet.id
    ip_address = try(local.privnet_static[each.key], null)
  }

  connection {
    type        = "ssh"
    host        = self.public_ip_address
    user        = data.exoscale_compute_template.node_template.username
    private_key = tls_private_key.ssh_key.private_key_openssh
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete (this may take some time) ...'",
      "sudo cloud-init status --wait >/dev/null",
      "sudo cloud-init status --long",
    ]
  }
}
