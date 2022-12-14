## Tests parameters
variable "test_name" {
  description = "Base name of the test infrastructure"
  type        = string
  default     = "tailscale"
}


## Exoscale parameters
variable "exoscale_api_key" {
  description = "Exoscale API key. If unspecified, will be read from environment variable (EXOSCALE_API_KEY)."
  type        = string
  default     = ""
}

variable "exoscale_api_secret" {
  description = "Exoscale API secret. If unspecified, will be read from environment variable (EXOSCALE_API_SECRET)."
  type        = string
  default     = ""
}

variable "exoscale_zone" {
  description = "Exoscale zone"
  type        = string
  default     = "ch-gva-2"
}

variable "exoscale_environment" {
  description = "Exoscale environment (accepted values: 'prod' or 'preprod')"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["prod", "preprod"], var.exoscale_environment)
    error_message = "'exoscale_environment' must be either 'prod' or 'preprod'"
  }
}

# Instances parameters
variable "exoscale_instance_template" {
  description = "Exoscale instance template"
  type        = string
  default     = "Linux Ubuntu 22.04 LTS 64-bit"
}


## Tailscale parameters
variable "tailscale_gateway_routes" {
  # REF: https://tailscale.com/kb/1019/subnets/
  description = "Tailscale gateway advertised routes"
  type        = list(string)
  default = [
    # Exoscale (RIPE-d)
    # (IPv4)
    # "85.217.160.0/22",
    # "85.217.172.0/22",
    # "85.217.184.0/22",
    # "89.145.160.0/21",
    # "91.92.116.0/22",
    # "91.92.140.0/22",
    # "91.92.152.0/22",
    # "91.92.200.0/22",
    # "91.92.224.0/22",
    # "138.124.208.0/20",
    # "159.100.240.0/20",
    # "185.19.28.0/22",
    # "185.150.8.0/22",
    # "194.182.160.0/19",
    # (IPv6)
    "2a04:c40::/29",
    "2a07:6cc0::/29",
  ]
}

variable "tailscale_auth_key" {
  # REF: https://tailscale.com/kb/1085/auth-keys/
  description = "Tailscale node authentication key. If unspecified, manual login is required."
  type        = string
  default     = ""
}
