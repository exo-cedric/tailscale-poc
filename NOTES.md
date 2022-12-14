Tailscale
=====

Install
-----

REFs:
- https://tailscale.com/kb/1031/install-linux/
- https://tailscale.com/kb/1187/install-ubuntu-2204/

``` bash
# Install the APT (GnuPG) key
wget -qO- https://pkgs.tailscale.com/stable/$(lsb_release -si | tr '[:upper:]' '[:lower:]')/$(lsb_release -sc).gpg \
| gpg --dearmor \
> /etc/apt/trusted.gpg.d/tailscale.gpg

# Install the APT source
wget -qO- https://pkgs.tailscale.com/stable/$(lsb_release -si | tr '[:upper:]' '[:lower:]')/$(lsb_release -sc).list \
> /etc/apt/sources.list.d/tailscale.list

# Check packaging
apt-get update

apt-cache policy tailscale | head -n 3
# [output]
```

``` text
tailscale:
  Installed: (none)
  Candidate: 1.32.3
```

``` bash
apt-cache show tailscale=1.32.3
# [output]
```

``` text
Package: tailscale
Version: 1.32.3
Section: net
Priority: extra
Architecture: amd64
Maintainer: Tailscale Inc <info@tailscale.com>
Installed-Size: 38197
Replaces: tailscale-relay
Depends: iptables, iproute2
Conflicts: tailscale-relay
Homepage: https://www.tailscale.com
Description: The easiest, most secure, cross platform way to use WireGuard + oauth2 + 2FA/SSO
Description-md5: 462dd30b4d95dc4099c71a8cf1301155
Filename: pool/tailscale_1.32.3_amd64.deb
Size: 21054530
MD5sum: 4267637971a8ec7d933fd67d8d246a72
SHA1: 4f70c304c3811ec533bdf62d53fab2b580eabcd3
SHA256: bd875e92f301065404715a353f462b792a9ba5931aa0dac677ee0889171d2dae
```

``` bash
# Install
apt-get install tailscale
```


Installed
-----

``` bash
# Package content
dpkg -L tailscale
# [output]
```

``` text
/lib/systemd/system/tailscaled.service
/usr/bin/tailscale
/usr/sbin/tailscaled
/etc/default/tailscaled
```

(mark: no `/usr/share/doc/tailscale` <-> changelog, license, etc.)

``` bash
# Tailscale daemon
tailscaled --help
# [output]
```

``` text
Usage of tailscaled:
  -bird-socket string
    	path of the bird unix socket
  -cleanup
    	clean up system state and exit
  -debug string
    	listen address ([ip]:port) of optional debug server
  -no-logs-no-support
    	disable log uploads; this also disables any technical support
  -outbound-http-proxy-listen string
    	optional [ip]:port to run an outbound HTTP proxy (e.g. "localhost:8080")
  -port value
    	UDP port to listen on for WireGuard and peer-to-peer traffic; 0 means automatically select (default 0)
  -socket string
    	path of the service unix socket (default "/var/run/tailscale/tailscaled.sock")
  -socks5-server string
    	optional [ip]:port to run a SOCK5 server (e.g. "localhost:1080")
  -state string
    	absolute path of state file; use 'kube:<secret-name>' to use Kubernetes secrets or 'arn:aws:ssm:...' to store in AWS SSM; use 'mem:' to not store state and register as an ephemeral node. If empty and --statedir is provided, the default is <statedir>/tailscaled.state. Default: /var/lib/tailscale/tailscaled.state
  -statedir string
    	path to directory for storage of config state, TLS certs, temporary incoming Taildrop files, etc. If empty, it's derived from --state when possible.
  -tun string
    	tunnel interface name; use "userspace-networking" (beta) to not use TUN (default "tailscale0")
  -verbose int
    	log verbosity level; 0 is default, 1 or higher are increasingly verbose
  -version
    	print version information and exit
```

``` bash
# <-> systemd
systemctl cat tailscaled.service
# [output]
```

``` text
# /lib/systemd/system/tailscaled.service
[Unit]
Description=Tailscale node agent
Documentation=https://tailscale.com/kb/
Wants=network-pre.target
After=network-pre.target NetworkManager.service systemd-resolved.service

[Service]
EnvironmentFile=/etc/default/tailscaled
ExecStartPre=/usr/sbin/tailscaled --cleanup
ExecStart=/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --port=${PORT} $FLAGS
ExecStopPost=/usr/sbin/tailscaled --cleanup

Restart=on-failure

RuntimeDirectory=tailscale
RuntimeDirectoryMode=0755
StateDirectory=tailscale
StateDirectoryMode=0700
CacheDirectory=tailscale
CacheDirectoryMode=0750
Type=notify

[Install]
WantedBy=multi-user.target
```

``` bash
# Tailscale user agent (<-> daemon)
tailscale --help
# [output]
```

``` text
USAGE
  tailscale [flags] <subcommand> [command flags]

For help on subcommands, add --help after: "tailscale status --help".

This CLI is still under active development. Commands and flags will
change in the future.

SUBCOMMANDS
  up         Connect to Tailscale, logging in if needed
  down       Disconnect from Tailscale
  logout     Disconnect from Tailscale and expire current node key
  netcheck   Print an analysis of local network conditions
  ip         Show Tailscale IP addresses
  status     Show state of tailscaled and its connections
  ping       Ping a host at the Tailscale layer, see how it routed
  nc         Connect to a port on a host, connected to stdin/stdout
  ssh        SSH to a Tailscale machine
  version    Print Tailscale version
  web        Run a web server for controlling Tailscale
  file       Send or receive files
  bugreport  Print a shareable identifier to help diagnose issues
  cert       get TLS certs
  lock       Manipulate the tailnet key authority
  licenses   Get open source license information

FLAGS
  --socket string
    	path to tailscaled's unix socket (default /var/run/tailscale/tailscaled.sock)
```

``` bash
dpkg -l | grep wireguard
# [no output]
```


Preliminary checks
-----

``` bash
# Display/check Tailscale networking internals
tailscale netcheck
# [output]
```

``` text
2022/12/01 16:23:13 No DERP map from tailscaled; using default.

Report:
	* UDP: true
	* IPv4: yes, <public-ipv4>:33298
	* IPv6: yes, [<public-ipv6>]:59495
	* MappingVariesByDestIP: false
	* HairPinning: false
	* PortMapping:
	* Nearest DERP: Frankfurt
	* DERP latency:
		- fra: 10.1ms  (Frankfurt)
		- par: 17.4ms  (Paris)
		- ams: 20.5ms  (Amsterdam)
		- lhr: 21ms    (London)
		- mad: 31.5ms  (Madrid)
		- waw: 32.5ms  (Warsaw)
		- tor: 109.8ms (Toronto)
		- nyc: 110.1ms (New York City)
		- ord: 110.2ms (Chicago)
		- mia: 111.6ms (Miami)
		- dfw: 115.9ms (Dallas)
		- blr: 119ms   (Bangalore)
		- dbi: 123.1ms (Dubai)
		- den: 130.5ms (Denver)
		- lax: 143.7ms (Los Angeles)
		- sea: 152.5ms (Seattle)
		- sfo: 157.6ms (San Francisco)
		- sin: 158.1ms (Singapore)
		- jnb: 178.3ms (Johannesburg)
		- hkg: 193.3ms (Hong Kong)
		- hnl: 195.4ms (Honolulu)
		- sao: 204.9ms (São Paulo)
		- syd:         (Sydney)
		- tok:         (Tokyo)
```


Enable the VPN
-----

``` bash
# Options
tailscale up --help
# [output]
```

``` text
USAGE
  up [flags]

"tailscale up" connects this machine to your Tailscale network,
triggering authentication if necessary.

With no flags, "tailscale up" brings the network online without
changing any settings. (That is, it's the opposite of "tailscale
down").

If flags are specified, the flags must be the complete set of desired
settings. An error is returned if any setting would be changed as a
result of an unspecified flag's default value, unless the --reset flag
is also used. (The flags --auth-key, --force-reauth, and --qr are not
considered settings that need to be re-specified when modifying
settings.)

FLAGS
  --accept-dns, --accept-dns=false
    	accept DNS configuration from the admin panel (default true)
  --accept-risk string
    	accept risk and skip confirmation for risk types: lose-ssh
  --accept-routes, --accept-routes=false
    	accept routes advertised by other Tailscale nodes (default false)
  --advertise-exit-node, --advertise-exit-node=false
    	offer to be an exit node for internet traffic for the tailnet (default false)
  --advertise-routes string
    	routes to advertise to other nodes (comma-separated, e.g. "10.0.0.0/8,192.168.0.0/24") or empty string to not advertise routes
  --advertise-tags string
    	comma-separated ACL tags to request; each must start with "tag:" (e.g. "tag:eng,tag:montreal,tag:ssh")
  --auth-key string
    	node authorization key; if it begins with "file:", then it's a path to a file containing the authkey
  --exit-node string
    	Tailscale exit node (IP or base name) for internet traffic, or empty string to not use an exit node
  --exit-node-allow-lan-access, --exit-node-allow-lan-access=false
    	Allow direct access to the local network when routing traffic via an exit node (default false)
  --force-reauth, --force-reauth=false
    	force reauthentication (default false)
  --host-routes, --host-routes=false
    	install host routes to other Tailscale nodes (default true)
  --hostname string
    	hostname to use instead of the one provided by the OS
  --json, --json=false
    	output in JSON format (WARNING: format subject to change) (default false)
  --login-server string
    	base URL of control server (default https://controlplane.tailscale.com)
  --netfilter-mode string
    	netfilter mode (one of on, nodivert, off) (default on)
  --operator string
    	Unix username to allow to operate on tailscaled without sudo
  --qr, --qr=false
    	show QR code for login URLs (default false)
  --reset, --reset=false
    	reset unspecified settings to their default values (default false)
  --shields-up, --shields-up=false
    	don't allow incoming connections (default false)
  --snat-subnet-routes, --snat-subnet-routes=false
    	source NAT traffic to local routes advertised with --advertise-routes (default true)
  --ssh, --ssh=false
    	run an SSH server, permitting access per tailnet admin's declared policy (default false)
  --timeout duration
    	maximum amount of time to wait for tailscaled to enter a Running state; default (0s) blocks forever (default 0s)
```

``` bash
# Enable the VPN
# (with default settings)
tailscale up
# [output]
```

``` text
To authenticate, visit:
	https://login.tailscale.com/a/<code>
Success.
```

``` bash
# Query VPN status
tailscale status --json
# [output]
```

``` json
{
  "Version": "1.32.3-ta07555f43-g093d1e978",
  "BackendState": "Running",
  "AuthURL": "",
  "TailscaleIPs": [
    "100.82.81.70",
    "fd7a:115c:a1e0:ab12:4843:cd96:6252:5146"
  ],
  "Self": {
    "ID": "<node-id>",
    "PublicKey": "nodekey:<nodes-key>",
    "HostName": "<hostname>",
    "DNSName": "<hostname>.tail<dns-id>.ts.net.",
    "OS": "linux",
    "UserID": "<user-id>",
    "TailscaleIPs": [
      "100.82.81.70",
      "fd7a:115c:a1e0:ab12:4843:cd96:6252:5146"
    ],
    "Addrs": [
      "<public-ipv4>:41641",
      "[<public-ipv6>]:41641",
      "<private-ipv4>:41641",
    ],
    "CurAddr": "",
    "Relay": "fra",
    "RxBytes": 0,
    "TxBytes": 0,
    "Created": "0001-01-01T00:00:00Z",
    "LastWrite": "0001-01-01T00:00:00Z",
    "LastSeen": "0001-01-01T00:00:00Z",
    "LastHandshake": "0001-01-01T00:00:00Z",
    "Online": true,
    "KeepAlive": false,
    "ExitNode": false,
    "ExitNodeOption": false,
    "Active": false,
    "PeerAPIURL": [
      "http://100.82.81.70:43900",
      "http://[fd7a:115c:a1e0:ab12:4843:cd96:6252:5146]:43900"
    ],
    "Capabilities": [
      "https://tailscale.com/cap/is-admin",
      "https://tailscale.com/cap/file-sharing",
      "https://tailscale.com/cap/ssh"
    ],
    "InNetworkMap": false,
    "InMagicSock": false,
    "InEngine": false
  },
  "Health": null,
  "MagicDNSSuffix": "tail<dns-id>.ts.net",
  "CurrentTailnet": {
    "Name": "<username>",
    "MagicDNSSuffix": "tail<dns-id>.ts.net",
    "MagicDNSEnabled": true
  },
  "CertDomains": null,
  "Peer": null,
  "User": {
    "<user-id>": {
      "ID": "<user-id>",
      "LoginName": "<username>",
      "DisplayName": "Cédric Dufour @ Exoscale",
      "ProfilePicURL": "https://avatars.githubusercontent.com/u/52404108?v=4",
      "Roles": []
    }
  }
}
```


Networking
-----

### Defaults

``` bash
# Enable the VPN
# (with default settings)
tailscale up

# Link/device
ip link show dev tailscale0
# [output]
```

``` text
78: tailscale0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1280 qdisc pfifo_fast
    state UNKNOWN mode DEFAULT group default qlen 500 link/none
```

``` bash
# Routing
ip route list table all | grep tailscale | sort
# [output]
```

``` text
100.100.100.100 dev tailscale0 table 52  # <<< MagicDNS server
100.123.207.30 dev tailscale0 table 52  # <<< Peer (remote Subnet Router)
fd7a:115c:a1e0:ab12:4843:cd96:6252:5146 dev tailscale0 proto kernel metric 256 pref medium
fe80::/64 dev tailscale0 proto kernel metric 256 pref medium
local 100.82.81.70 dev tailscale0 table local proto kernel scope host src 100.82.81.70
local fd7a:115c:a1e0:ab12:4843:cd96:6252:5146 dev tailscale0 table local proto kernel metric 0 pref medium
local fe80::36e5:c6bb:fcef:cf16 dev tailscale0 table local proto kernel metric 0 pref medium
multicast ff00::/8 dev tailscale0 table local proto kernel metric 256 pref medium
```

``` bash
# DNS
cat /etc/resolv.conf
# [output]
```

``` text
# resolv.conf(5) file generated by tailscale
# DO NOT EDIT THIS FILE BY HAND -- CHANGES WILL BE OVERWRITTEN
nameserver 100.100.100.100  # <<< MagicDNS server
search tail<dns-id>.ts.net cedric.exoscale.me
```


### External operator

``` bash
# Enable the VPN
# With "external operator" settings:
#   --accept-dns=false    # <<< disable MagicDNS
#   --accept-routes=true  # <<< import Subnet Router(s) --advertised-routes
#   --host-routes=false   # <<< do-not import peer(s) Tailscale IP addresses
#   --shields-up=true     # <<< block incoming connections
tailscale up \
  --reset \
  --accept-dns=false \
  --accept-routes=true \
  --host-routes=false \
  --shields-up=true

# Routing
ip route list table all | grep tailscale | sort
# [output]
```

``` text
100.100.100.100 dev tailscale0 table 52  # <<< MagicDNS server
10.42.168.0/24 dev tailscale0 table 52    # <<< Subnet Router --advertised-routes
fd7a:115c:a1e0:ab12:4843:cd96:6252:5146 dev tailscale0 proto kernel metric 256 pref medium
fe80::/64 dev tailscale0 proto kernel metric 256 pref medium
local 100.82.81.70 dev tailscale0 table local proto kernel scope host src 100.82.81.70
local fd7a:115c:a1e0:ab12:4843:cd96:6252:5146 dev tailscale0 table local proto kernel metric 0 pref medium
local fe80::36e5:c6bb:fcef:cf16 dev tailscale0 table local proto kernel metric 0 pref medium
multicast ff00::/8 dev tailscale0 table local proto kernel metric 256 pref medium
```

``` bash
# DNS
cat /etc/resolv.conf
# [output]
```

``` text
# Generated by NetworkManager
search cedric.exoscale.me
[ ... ]
```

``` bash
# INPUT (IPv6)
ip6tables -nvL ts-input
# [output]
```

``` text
Chain ts-input (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     all      lo     *       fd7a:115c:a1e0:ab12:4843:cd96:6252:5146  ::/0
```

``` bash
# FORWARD (IPv6)
iptables -nvL ts-forward
# [output]
```

``` text
Chain ts-forward (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MARK       all      tailscale0 *       ::/0                 ::/0                 MARK xset 0x40000/0xff0000
    0     0 ACCEPT     all      *      *       ::/0                 ::/0                 mark match 0x40000/0xff0000
    0     0 ACCEPT     all      *      tailscale0  ::/0                 ::/0
```


### ACLs enforcement (on Subnet Router)

It appears ACLs are managed by `tailscaled` itself and _not_ `ip(6)tables`:

``` bash
# INPUT (IPv6)
ip6tables -nvL ts-input
# [output]
```

``` text
Chain ts-input (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     all      lo     *       fd7a:115c:a1e0:ab12:4843:cd96:6240:9750  ::/0
```

``` bash
# FORWARD (IPv6)
ip6tables -nvL ts-forward
# [output]
```

``` text
Chain ts-forward (1 references)
 pkts bytes target     prot opt in     out     source               destination
  117 15280 MARK       all      tailscale0 *       ::/0                 ::/0                 MARK xset 0x40000/0xff0000
  117 15280 ACCEPT     all      *      *       ::/0                 ::/0                 mark match 0x40000/0xff0000
  100 13392 ACCEPT     all      *      tailscale0  ::/0                 ::/0
```

``` bash
# Tailscale "firewalling"
journalctl -u tailscaled -f
# [outtut]
```

``` test
# ACL-accepted
Dec 13 14:39:01 tailscale-35o98-gateway tailscaled[13428]: Accept: ICMPv6{[fd7a:115c:a1e0:ab12:4843:cd96:6252:5146]:0 > [2a04:c43:e00:620e:417:40ff:fe00:1219]:0} 104 icmp ok
Dec 13 14:39:11 tailscale-35o98-gateway tailscaled[13428]: Accept: ICMPv6{[fd7a:115c:a1e0:ab12:4843:cd96:6252:5146]:0 > [2a04:c43:e00:620e:417:40ff:fe00:1219]:0} 104 icmp ok

# ACL-denied
Dec 13 14:58:55 tailscale-35o98-gateway tailscaled[13428]: Drop: ICMPv6{[fd7a:115c:a1e0:ab12:4843:cd96:6252:5146]:0 > [2a04:c43:e00:620e:417:40ff:fe00:1219]:0} 104 no rules matched
Dec 13 14:58:56 tailscale-35o98-gateway tailscaled[13428]: Drop: ICMPv6{[fd7a:115c:a1e0:ab12:4843:cd96:6252:5146]:0 > [2a04:c43:e00:620e:417:40ff:fe00:1219]:0} 104 no rules matched
```
