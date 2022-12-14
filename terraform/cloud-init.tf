## cloud-init configuration (compute node 'user-data')
#  REF: https://cloudinit.readthedocs.io/en/latest/topics/format.html#part-handler

# cloudinit_config
# REF: https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/cloudinit_config
data "cloudinit_config" "user_data" {
  for_each = toset(["gateway", "internal"])

  gzip          = false
  base64_encode = false

  # cloud-config
  part {
    filename     = "init.cfg"
    content_type = "text/jinja2"
    content = templatefile(
      "${path.module}/resources/cloud-init.yaml",
      {
        node_type = each.key

        # System setup
        # (APT)
        apt_key_tailscale = file("${path.module}/resources/system/etc/apt/trusted.gpg.d/tailscale.gpg")
        # (networking)
        sysctl_ip_forwarding = file("${path.module}/resources/system/etc/sysctl.d/99-ip-forwarding.conf")

        # Resources
        tailscale_up = templatefile(
          "${path.module}/resources/system/usr/local/sbin/tailscale-up",
          {
            auth_key         = var.tailscale_auth_key
            advertise_tags   = [each.key]
            advertise_routes = (each.key == "gateway") ? flatten(["${local.privnet_network}/${local.privnet_netcidr}", var.tailscale_gateway_routes]) : []
        })
        tailscale_auth_key = var.tailscale_auth_key
      }
    )
  }
}
