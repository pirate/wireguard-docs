<div align="center">

# The Missing Wireguard Documentation

<img src="https://i.imgur.com/xePt3qp.png"><br/><br/>


API reference guide for Wireguard including Setup, Configuration, and Usage, with full example.

Also published on https://docs.sweeting.me/s/wireguard.

</div>

---


This is my attempt at writing the "Missing Wireguard Documentation" to make up for the lacking offical docs for an otherwise great piece of software.

[WireGuard](https://www.wireguard.com/) is an open-source VPN solution written in Go, aiming to fix many of the problems that have plagued other good server-to-server VPN offerings like IPSec/IKEv2 or OpenVPN.

**WireGuard Goals**

 - strong, modern security by default
 - minimal config and key management
 - fast, both low-latency and high-bandwidth
 - simple internals and small protocol surface area
 - simple CLI and seamless integration with system networking

---

# Table of Contents

See https://docs.sweeting.me/s/wireguard.

# Intro

Over the last 8 years I've tried a wide range of VPN solutions.  From the original PPTP back in the early 2010's to break through the Great Firewall of China while I was living in Shanghai, to OpenVPN and IPSec/IKEv2 later on.  From the recommendation of a few people in the [RC](https://recurse.com) Zulip community, I decided to try WireGuard and was surprised to find it checked all the boxes.

## My Requirements for a VPN Solution

 - create a LAN like 10.0.0.0/24 between all my servers, every peer can connect to every peer
 - must be able to bust through middebox NATs/routers
 - requiring a central server for coordination/NAT busting is ok, but it shouldn't have to route all traffic through the central node if a direct connection is possible
 - wont be used for routing *all* traffic, only traffic to the VPN subnet (i.e. I'm not passing my web browsing through it, just server-to-server stuff like NFS/SSH/redis/etc)
 - robust automatic reconnects after reboots / network downtime
 - fast (lowest possible latency and line-rate bandwidth)
 - encrypted, but doesn't have to be super secure (i.e. doesn't have to be state-level secure or undetectable)
 - minimal config and key management overhead, 1 or 2 preshared keys or certs is ok, but ideally not both
 - support for any type of Level 2 traffic, e.g. UDP/ARP/ICMP (or ideally raw ethernet frames), not just TCP/HTTP
 - ability to join the VPN from Ubuntu, FreeBSD, iOS, macOS (ideally without needing an app), Windows/Android not needed but would be nice
 - not a requirement, but ideally it would support running in docker with a single container, config file, and preshared key on each server, but with a full network interface exposed to the host system (maybe with tun/tap on the host passing traffic to the container, but ideally just a single container without outside dependencies)

## List of Possible VPN Solutions


- PPTP: ancient, inflexible, insecure, doens't solve all the requirements
 - SOCKS: proxy tunnel, not a VPN, not great for this use case
- [IPSec (IKEv2)](https://github.com/jawj/IKEv2-setup)/strongSwan: lots of brittle config that's different for each OS, NAT busting setup is very manual and involves updating the central server and starting all the others in the correct order, not great at reconnecting after network downtime, had to be manually restarted often
- [TINC](https://www.tinc-vpn.org/): haven't tried it yet, but it doesn't work on iOS, worst case senario I could live with that if it's the only option
 - [OpenVPN](https://openvpn.net/vpn-server-resources/site-to-site-routing-explained-in-detail/): I don't like it from past experience but could be convinced if it's the only option
 - [Algo](https://github.com/trailofbits/algo): haven't tried it yet, should I?
 - [Striesand](https://github.com/StreisandEffect/streisand): haven't tried it yet, whats the best config to try?
 - [SoftEther](https://www.softether.org/): haven't tried it yet, should I?
 - [WireGuard](https://www.wireguard.com/): the subject of this post
 - [ZeroTier](https://www.zerotier.com): haven't tried it yet, sould I?

---

# Wireguard Documentation

## Glossary

### Peer/Node/Device

A host that connects to the VPN and has registers a VPN subnet address like 10.0.0.3 for itself. It can also optionally route traffic for more than its own address(es) by specifing subnet ranges in comma-separated CIDR notation.

### Bounce Server

A publicly reachable peer/node that serves as a fallback to relay traffic for other VPN peers behind NATs.

### Subnet

A group of IPs separate from the public internet, e.g. 10.0.0.1-255 or 192.168.1.1/24. Generally behind a NAT provided by a router, e.g. in office internet LAN or a home WiFi network.

### CIDR Notation

A way of defining the size of a subnet. Most common ones:
  + 10.0.0.1/32 (a single IP address, 10.0.0.1) netmask = 255.255.255.255
  + 10.0.0.1/24 (255 ips from 10.0.0.1-255) netmask =  255.255.255.0
  + 10.0.0.1/16 (65,536 ips from 10.0.0.0 - 10.0.255.255) netmask = 255.255.0.0
  + 10.0.0.1/8 (16,777,216 ips from 10.0.0.0 - 10.255.255.255) netmask = 255.0.0.0
  + 0.0.0.1/0 (4,294,967,296 ips from 0.0.0.0 - 255.255.255.255) netmask = 0.0.0.0
 
https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing

### NAT
A subnet with private IPs provided by a router standing in front of them doing Network Address Translation, individual nodes are not publicly accessible from the internet, instead the router keeps track of outgoing connections and forwards responses to the correct internal ip (e.g. standard office networks, home wifi networks, free public wifi networks, etc)

### Public Endpoint

The publicly accessible address:port for a node, e.g. `123.124.125.126:1234` or `some.domain.tld:1234` (must be accessible via the public internet, generally can't be a private ip like `10.0.0.1` or `192.168.1.1` unless it's directly accessible using that address by other peers on the same subnet).


### Private key
A wireguard private key for a single node, generated with:
`wg genkey > example.key`
(never leaves the node it's generated on)
  
### Public key
A wireguard public key for a single node, generated with:
`wg pubkey < example.key > example.key.pub `
(shared with other peers)

### DNS

Domain Name Server, used to resolve hostnames to IPs for VPN clients, instead of allowing DNS requests to leak outside the VPN and reveal traffic.  Leaks are testable with http://dnsleak.com.

## Usage

### Quickstart

Overview of the general process:

0. Install `wireguard` or `wireguard-tools` on each node
1. Generate public and private keys locally on each node
2. Create a `wg0.conf` wireguard config file on the main relay server
    - `[Interface]` Make sure to specify a CIDR range for the entire VPN subnet when defining the address the server accepts routes for `Address = 10.0.0.1/24`
    - `[Peer]` Create a peer section for every client joining the VPN, using their corresponding remote public keys
3. Crete a `wg0.conf` on each client node
   - `[Interface]` Make sure to specify only a single IP for client peers that don't relay traffic `Address = 10.0.0.3/32`.
   - `[Peer]` Create a peer section for each public peer not behind a NAT, make sure to specify a CIDR range for the entire VPN subnet when defining the remote peer acting as the bounce server `AllowedIPs = 10.0.0.1/24`. Make sure to specify individual IPs for remote peers that don't relay traffic and only act as simple clients `AllowedIPs = 10.0.0.3/32`.
4. Start wireguard on the main relay server with `wg-quick up /full/path/to/wg0.conf`
5. Start wireguard on all the client peers with `wg-quick up /full/path/to/wg0.conf`
6. Traffic is routed from peer to peer using most optimal route over the WireGuard interface, e.g. `ping 10.0.0.3` checks for local direct route first, then checks for route via public internet, then finally tries to route by bouncing through the public relay server.

### Setup

```bash
# install on Ubuntu
sudo add-apt-repository ppa:wireguard/wireguard
apt install wireguard

# install on macOS
brew install wireguard-tools

# install on FreeBSD
pkg install wireguard

# install on iOS/Andoid using Apple App Store/Google Play Store
# install on other systems using https://www.wireguard.com/install/#installation
```

```
# to enable kernel relaying/forwarding ability on bounce servers
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.proxy_arp" >> /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

# to add iptables forwarding rules on bounce servers
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
```

### Config Creation
```bash
nano wg0.conf  # can be placed anywhere, must be referred to using absolute path
```

### Key Generation

```bash
# generate private key
wg genkey > example.key

# generate public key
wg pubkey < example.key > example.key.pub
```

### Start / Stop

```bash
wg-quick up /full/path/to/wg0.conf
wg-quick down /full/path/to/wg0.conf
```

```bash
# start/stop VPN network interface
ip link set wg0 up
ip link set wg0 down

# register/unregister VPN network interface
ip link add dev wg0 type wireguard
ip link delete dev wg0

# register/unregister local VPN address
ip address add dev wg0 10.0.0.3/32
ip address delete dev wg0 10.0.0.3/32

# register/unregister VPN route
ip route add 10.0.0.3/32 dev wg0
ip route delete 10.0.0.3/32 dev wg0
```


### Inspect

#### Interfaces

```bash
# show system LAN and WAN network interfaces
ifconfig
ip address show

# show system VPN network interfaces
ifconfig wg0
ip link show wg0

# show wireguard VPN interfaces
wg show all
wg show wg0
```

#### Addresses

```bash
# show public ip address
ifconfig eth0
ip address show eth0
dig -4 +short myip.opendns.com @resolver1.opendns.com

# show VPN ip address
ip address show wg0
```

#### Routes

```bash
# show wireguard routing table and peer connections
wg show
wg show wg0 allowed-ips

# show system routing table
ip route show table main
ip route show table local

# show system route to specific address
ip route get 10.0.0.3
```

### Testing

#### Ping Speed
```bash
# check that main relay server is accesible directly via public internet
ping public-server1.example-vpn.dev

# check that the main relay server is available via VPN
ping 10.0.0.1

# check that public peers are available via VPN
ping 10.0.0.2

# check that remote NAT-ed peers are available via VPN
ping 10.0.0.3

# check that NAT-ed peers in your local lan are available via VPN
ping 10.0.0.4
```

#### Bandwidth


```bash
# check bandwidth over public internet to relay server
iperf -s # on public relay server
iperf -c public-server1.example-vpn.dev # on local client

# check bandwidth over VPN to relay server
iperf -s # on public relay server
iperf -c 10.0.0.1 # on local client

# check bandwidth over VPN to remote public peer
iperf -s # on remote public peer
iperf -c 10.0.0.2 # on local client

# check bandwidth over VPN to remote NAT-ed peer
iperf -s # on remote NAT-ed peer
iperf -c 10.0.0.3 # on local client

# check bandwidth over VPN to local NAT-ed peer (on same LAN)
iperf -s # on local NAT-ed peer
iperf -c 10.0.0.4 # on local client
```


## Config Reference

### `[Interface]`

Defines the VPN settings for the local node.

**Examples**

* Node is a client that only routes traffic for itself and only exposes one IP
```ini
[Interface]
# Name = phone.example-vpn.dev
Address = 10.0.0.5/32
PrivateKey = <private key for phone.example-vpn.dev>
```
* Node is a public bounce server that can relay traffic to other peers and exposes route for entire VPN subnet
```ini
[Interface]
# Name = public-server1.example-vpn.tld
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <private key for public-server1.example-vpn.tld>
DNS = 1.1.1.1
```

#### `# Name`

This is just a standard comment in INI syntax used to help keep track of which config section belongs to which node, it's completely ignored by WireGuard and has no effect on VPN behavior.

#### `Address`

Defines what address range the local node should route traffic for. Depending on whether the node is a simple client joining the VPN subnet, or a bounce server that's relaying traffic between multiple clients, this can be set to a single IP of the node itself (specificed with CIDR notation), e.g. 10.0.0.3/32), or a range of IPv4/IPv6 subnets that the node can route traffic for.

**Examples**

* Node is a client that only routes traffic for itself

`Address = 10.0.0.3/32`

* Node is a public bounce server that can relay traffic to other peers

When the node is acting as the public bounce server, it should set this to be the entire subnet that it can route traffic, not just a single IP for itself.

`Address = 10.0.0.1/24`

* You can also specify multiple subnets or IPv6 subnets like so:

`Address = 10.0.0.1/24,fd42:42:42::1/64`

#### `ListenPort`

When the node is acting as a public bounce server, it should hardcode a port to listen for incoming VPN connections from the public internet.  Clients not acting as relays should not set this value.

**Examples**

* Using default WireGuard port
`ListenPort = 51820`
* Using custom WireGuard port
`ListenPort = 7000`

#### `PrivateKey`

This is the private key for the local node, never shared with other servers.
All nodes must have a private key set, regardless of whether they are public bounce servers relaying traffic, or simple clients joining the VPN.

This key can be generated with `wg genkey > example.key`

**Examples**

`PrivateKey = somePrivateKeyAbcdAbcdAbcdAbcd=`

#### `DNS`

The DNS server(s) to announce to VPN clients via DHCP, most clients will use this server for DNS requests over the VPN, but clients can also override this value locally on their nodes

**Examples**

* The value can be left unconfigured to use system default DNS servers
* A single DNS server can be provided
`DNS = 1.1.1.1`
* or multiple DNS servers can be provided
`DNS = 1.1.1.1,8.8.8.8`

### `[Peer]`

Defines the VPN settings for a remote peer capable of routing traffic for one or more addresses (itself and/or other peers). Peers can be either a public bounce server that relays traffic to other peers, a directly accessible client via lan/internet that is not behind a NAT and only routes traffic for itself.

All clients must be defined as peers on the public bounce server, however on the simple clients that only route traffic for themselves, only the public relay and other directly accessible nodes need to be defined as peeers. Nodes that are behind separate NATs should not be defined as peers outside of the public server config, as no specific direct route is available between separate NATs. Instead, nodes behind NATs should only define the public relay servers and other public clients as their peers, and should specify `AllowedIPs = 10.0.0.1/24` on the public server that accept routes and bounce traffic to the remote NAT-ed peers.

In summary, all nodes must be defined on the main bounce server.  On client servers, only peers that are directly accessible from a node should be defined as peers of that node, any peers that must be relayed by a bounce sherver should be left out and will be handled by the relay server's catchall route.

In the configuration outlined in the docs below, a single server `public-server1` acts as the relay bounce server for a mix of publicly accessible and NAT-ed clients, and peers are configured on each node accordingly:

- on public-server1 (bounce server):
  `peers = public-server2,home-server,laptop,phone`
- on public-server2 (simple public client):
  `peers = public-server1`
- on home-server (simple client behind nat):
  `peers = public-server1,public-server2`
- on laptop (simple client behind nat):
  `peers = public-server1,public-server2`
- on phone (simple client behind nat):
  `peers = public-server1,public-server2`

**Examples**

* Peer is a simple public client that only routes traffic for itself
```ini
[Peer]
# Name = public-server2.example-vpn.dev
Endpoint = public-server2.example-vpn.dev:51820
PublicKey = <public key for public-server2.example-vpn.dev>
AllowedIPs = 10.0.0.2/32
```

* Peer is a simple client behind a NAT that only routes traffic for itself
```ini
[Peer]
# Name = home-server.example-vpn.dev
Endpoint = home-server.example-vpn.dev:51820
PublicKey = <public key for home-server.example-vpn.dev>
AllowedIPs = 10.0.0.3/32
```

* Peer is a public bounce server that can relay traffic to other peers
```ini
[Peer]
# Name = public-server1.example-vpn.tld
Endpoint = public-server1.example-vpn.tld:51820
PublicKey = <public key for public-server1.example-vpn.tld>
# routes traffic to itself and entire subnet of peers as bounce server
AllowedIPs = 10.0.0.1/24
PersistentKeepalive = 25
```

#### `# Name`

This is just a standard comment in INI syntax used to help keep track of which config section belongs to which node, it's completely ignored by WireGuard and has no effect on VPN behavior.

#### `Endpoint`

Defines the publicly accessible address for a remote peer.  This should be left out for peers behind a NAT or peers that don't have a stable publicly accessible IP:PORT pair.  Typically, this only needs to be defined on the main bounce server, but it can also be defined on other public nodes with stable IPs like `public-server2` in the example config below.

**Examples**

* Endpoint is an IP address
`Endpoint = 123.124.125.126:51820`
* Endpoint is a hostname/FQDN
`Endpoint = public-server1.example-vpn.tld:51820`

#### `AllowedIPs`

This defines the IP ranges that a peer will route traffic for. Usually this is a single address (the VPN address of the peer itself), but for bounce servers this will be a range of the IPs or subnets that the relay server is capable of routing traffic for.  Using comma-separated IPv4 or IPv6 CIDR notation, a single address can be defined as routable, or multiple ranges of IPs all the way up to `0.0.0.0/0` to route all internet and VPN traffic through that peer.

When deciding how to route a packet, the system chooses the most specific route first, and falls back to broader routes. So for a packet destined to `10.0.0.3`, the system would first look for a peer advertising `10.0.0.3/32` specifically, and would fall back to a peer advertising `10.0.0.1/24` or a larger range like `0.0.0.0/0` as a last resort.

**Examples**

* peer is a simple client that only accepts traffic to/from itself
`AllowedIPs = 10.0.0.3/32`
* peer is a relay server that can bounce VPN traffic to all other peers
`AllowedIPs = 10.0.0.1/24`
* peer is a relay server that bounces all internet & VPN traffic (like a proxy)
`AllowedIPs = 0.0.0.0/0,::/0`
* peer is a relay server that routes to itself and only one other peer
`AllowedIPs = 10.0.0.3/32,10.0.0.4/32`
* peer is a relay server that routes to itself and all nodes on its local LAN
`AllowedIPs = 10.0.0.3/32,192.168.1.1/24`

#### `PublicKey`

This is the public key for the remote node, sharable with all peers.
All nodes must have a public key set, regardless of whether they are public bounce servers relaying traffic, or simple clients joining the VPN.

This key can be generated with `wg pubkey < example.key > example.key.pub`.
(see above for how to generate the private key `example.key`)

**Examples**

`PublicKey = somePrivateKeyAbcdAbcdAbcdAbcd=`

#### `PersistentKeepalive`

If the connection is going from a NAT-ed peer to a public peer, the node behind the NAT must regularly send an outgoing ping in order to keep the bidirectional connection alive in the NAT router's connection table.

**Examples**

* local public node to remote public node
  This value should be left undefined as persistent pings are not needed.
* local public node to remote NAT-ed node
  This value should be left unefined as it's the client's responsibility to keep the connection alive because the server cannot reopen a dead connection to the client if it times out.
* local NAT-ed node to remote public node
`PersistentKeepalive = 25` this will send a ping to every 25 seconds keeping the connection open in the local NAT router's connection table.

# Example Server-To-Server Config with Roaming Devices

## Overview

### Network Topology

These 5 devices are used in our example setup to explain how WireGuard supports bridging across a variety of network conditions, they're all under an example domain `example-vpn.dev`, with the following short hostnames:

- `public-server1` (not behind a NAT, acts as the main VPN bounce server)
- `public-server2` (not behind a NAT, joins as a peer without bouncing traffic)
- `home-server` (behind a NAT, joins as a peer without bouncing traffic)
- `laptop` (behind NAT, sometimes shared w/ home-server/phone, sometimes roaming)
- `phone` (behind NAT, sometimes shared w/ home-server/laptop, sometimes roaming)

### Explanation

This VPN config simulates setting up a small VPN subnet 10.0.0.1/24 shared by 5 nodes. Two of the nodes (public-server1 and public-server2) are VPS instances living in a cloud somewhere, with public IPs accessible to the internet.  home-server is a stationary node that lives behind a NAT with a dynamic IP, but it doesn't change frequently. Phone and laptop are both roaming nodes, that can either be at home in the same LAN as home-server, or out-and-about using public wifi or cell service to connect to the VPN.

Whenever possible, nodes should connect directly to eachother, depending on whether nodes are directly accessible or NATs are between them, traffic will route accordinly:

### How Public Relays Work

`public-server1` acts as an intermediate relay server between any VPN clients behind NATs, it will forward any 10.0.0.1/24 traffic it receives to the correct peer at the system level (WireGuard doesn't care how this happens, it's handled by the kernel `net.ipv4.ip_forward = 1` and the iptables routing rules).

Each client only needs to define the publicly accessible servers/peers in it's config, any traffic bound to other peers behind NATs will go to the catchall 10.0.0.1/24 for the server and will be forwarded accordingly once it hits the main server.

In summary: only direct connections between clients should be configured, any connections that need to be bounced should not be defined as peers, as they should head to the bounce server first and be routed from there back down the vpn to the correct client.

### How WireGuard Routes Packets

- **Direct node-to-node**
  In the best case, the nodes are on the same LAN and traffic will route directly between them on the local connection.
- **Node behind NAT to public node**
  When 1 of the 2 parties is behind a remote NAT (e.g. when laptop behind a NAT connects to public-server2), the connection will be opened from NAT -> public client, then traffic will route directly between them in both directions as long as the connection is kept alive.
- **Node behind NAT to node behind separate NAT**
  In the worst case when both parties are behind separate NATs, both will open a connection to public-server1, and traffic will forward through the intermediary bounce server as long as the connections are kept alive.

Chosing the proper routing method is handled automatically by WireGuard as long as the bounce server has `net.ipv4.ip_forward = 1` enabled, and clients have `AllowIPs = 10.0.0.1/24` under the bounce server's peer definition so that it can accept traffic for all IPs in the subnet.  More specific (usually more direct) routes provided by other peers will take precedence when available, otherwise traffic will fall back to the least specific route and use the `10.0.0.1/24` catchall to forward traffic to the bounce server, where it will in turn be routed by the bounce system back to the specific peer thats accepting routes for that traffic.

## Node Config

### public-server1.example-vpn.tld
 * public endpoint: `public-server1.example-vpn.tld:51820` 
 * own vpn ip address: `10.0.0.1`
 * can accept traffic for ips: `10.0.0.1/24`
 * priv key: `<private key for public-server1.example-vpn.tld>`
 * pub key: `<public key for public-server1.example-vpn.tld>`
 * setup required:
 	1. install wireguard
 	2. generate public/private keypair
 	3. create wg0.conf (see below)
 	4. enable kernel ip & arp forwarding, add iptables forwarding rules
 	5. start wireguard
 * config as remote peer:
```ini
[Peer]
# Name = public-server1.example-vpn.tld
Endpoint = public-server1.example-vpn.tld:51820
PublicKey = <public key for public-server1.example-vpn.tld>
# routes traffic to itself and entire subnet of peers as bounce server
AllowedIPs = 10.0.0.1/24
PersistentKeepalive = 25
```
 * config as local interface:
```ini
[Interface]
# Name = public-server1.example-vpn.tld
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <private key for public-server1.example-vpn.tld>
DNS = 1.1.1.1
```
 * peers: public-server2, home-server, laptop, phone
 * full `wg0.conf` config file for node:
```ini
[Interface]
# Name = public-server1.example-vpn.tld
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <private key for public-server1.example-vpn.tld>
DNS = 1.1.1.1

[Peer]
# Name = public-server2.example-vpn.dev
Endpoint = public-server2.example-vpn.dev:51820
PublicKey = <public key for public-server2.example-vpn.dev>
AllowedIPs = 10.0.0.2/32

[Peer]
# Name = home-server.example-vpn.dev
Endpoint = home-server.example-vpn.dev:51820
PublicKey = <public key for home-server.example-vpn.dev>
AllowedIPs = 10.0.0.3/32

[Peer]
# Name = laptop.example-vpn.dev
PublicKey = <public key for laptop.example-vpn.dev>
AllowedIPs = 10.0.0.4/32

[Peer]
# phone.example-vpn.dev
PublicKey = <public key for phone.example-vpn.dev>
AllowedIPs = 10.0.0.5/32
```

### public-server2.example-vpn.dev
 * public endpoint: `public-server2.example-vpn.dev:51820` 
 * own vpn ip address: `10.0.0.2`
 * can accept traffic for ips: `10.0.0.2/32`
 * priv key: `<private key for public-server2.example-vpn.dev>`
 * pub key: `<public key for public-server2.example-vpn.dev>`
 * setup required:
 	1. install wireguard
 	2. generate public/private keypair
 	3. create wg0.conf (see below)
 	4. confirm main public relay server is directly accessible
 	4. start wireguard
 * config as local interface:
```ini
[Interface]
# Name = public-server2.example-vpn.dev
Address = 10.0.0.2/32
ListenPort = 51820
PrivateKey = <private key for public-server2.example-vpn.dev>
DNS = 1.1.1.1
```
 * config as peer:
```ini
[Peer]
# Name = public-server2.example-vpn.dev
Endpoint = public-server2.example-vpn.dev:51820
PublicKey = <public key for public-server2.example-vpn.dev>
AllowedIPs = 10.0.0.2/32
```
 * peers: public-server1
 * full `wg0.conf` config file for node:
```ini
[Interface]
# Name = public-server2.example-vpn.dev
Address = 10.0.0.2/32
ListenPort = 51820
PrivateKey = <private key for public-server2.example-vpn.dev>
DNS = 1.1.1.1

[Peer]
# Name = public-server1.example-vpn.tld
Endpoint = public-server1.example-vpn.tld:51820
PublicKey = <public key for public-server1.example-vpn.tld>
# routes traffic to itself and entire subnet of peers as bounce server
AllowedIPs = 10.0.0.1/24
PersistentKeepalive = 25
```

### home-server.example-vpn.dev
 * public endpoint: (none, behind NAT)
 * own vpn ip address: `10.0.0.3`
 * can accept traffic for ips: `10.0.0.3/32`
 * priv key: `<private key for home-server.example-vpn.dev>`
 * pub key: `<public key for home-server.example-vpn.dev>`
 * setup required:
 	1. install wireguard
 	2. generate public/private keypair
 	3. create wg0.conf (see below)
 	4. confirm main public relay server is directly accessible
 	4. start wireguard
 * config as local interface:
```ini
[Interface]
# Name = home-server.example-vpn.dev
Address = 10.0.0.3/32
ListenPort = 51820
PrivateKey = <private key for home-server.example-vpn.dev>
DNS = 1.1.1.1
```
 * config as peer:
```ini
[Peer]
# Name = home-server.example-vpn.dev
Endpoint = home-server.example-vpn.dev:51820
PublicKey = <public key for home-server.example-vpn.dev>
AllowedIPs = 10.0.0.3/32
```
 * peers: public-server1
 * full `wg0.conf` config file for node:
```ini
[Interface]
# Name = home-server.example-vpn.dev
Address = 10.0.0.3/32
ListenPort = 51820
PrivateKey = <private key for home-server.example-vpn.dev>
DNS = 1.1.1.1

[Peer]
# Name = public-server1.example-vpn.tld
Endpoint = public-server1.example-vpn.tld:51820
PublicKey = <public key for public-server1.example-vpn.tld>
# routes traffic to itself and entire subnet of peers as bounce server
AllowedIPs = 10.0.0.1/24
PersistentKeepalive = 25
```

### laptop.example-vpn.dev
 * public endpoint: (none, behind NAT)
 * own vpn ip address: `10.0.0.4`
 * can accept traffic for ips: `10.0.0.4/32`
 * priv key: `<private key for laptop.example-vpn.dev>`
 * pub key: `<public key for laptop.example-vpn.dev>`
 * setup required:
 	1. install wireguard
 	2. generate public/private keypair
 	3. create wg0.conf (see below)
 	4. confirm main public relay server is directly accessible
 	4. start wireguard
 * config as local interface:
```ini
[Interface]
# Name = laptop.example-vpn.dev
Address = 10.0.0.4/32
PrivateKey = <private key for laptop.example-vpn.dev>
DNS = 1.1.1.1
```
 * config as peer:
```ini
[Peer]
# Name = laptop.example-vpn.dev
PublicKey = <public key for laptop.example-vpn.dev>
AllowedIPs = 10.0.0.4/32
```
 * peers: public-server1
 * full `wg0.conf` config file for node:
```ini
[Interface]
# Name = laptop.example-vpn.dev
Address = 10.0.0.4/32
PrivateKey = <private key for laptop.example-vpn.dev>
DNS = 1.1.1.1

[Peer]
# Name = public-server1.example-vpn.tld
Endpoint = public-server1.example-vpn.tld:51820
PublicKey = <public key for public-server1.example-vpn.tld>
# routes traffic to itself and entire subnet of peers as bounce server
AllowedIPs = 10.0.0.1/24
PersistentKeepalive = 25
```

### phone.example-vpn.dev
 * public endpoint: (none, behind NAT)
 * own vpn ip address: `10.0.0.5`
 * can accept traffic for ips: `10.0.0.5/32`
 * priv key: `<private key for phone.example-vpn.dev>`
 * pub key: `<public key for phone.example-vpn.dev>`
 * setup required:
 	1. install wireguard
 	2. generate public/private keypair
 	3. create wg0.conf (see below)
 	4. confirm main public relay server is directly accessible
 	4. start wireguard
 * config as local interface:
```ini
[Interface]
# Name = phone.example-vpn.dev
Address = 10.0.0.5/32
PrivateKey = <private key for phone.example-vpn.dev>
DNS = 1.1.1.1
```
 * config as peer:
```ini
[Peer]
# phone.example-vpn.dev
PublicKey = <public key for phone.example-vpn.dev>
AllowedIPs = 10.0.0.5/32
```
 * peers: public-server1
 * full `wg0.conf` config file for node:
```ini
[Interface]
# Name = phone.example-vpn.dev
Address = 10.0.0.5/32
PrivateKey = <private key for phone.example-vpn.dev>
DNS = 1.1.1.1

[Peer]
# Name = public-server1.example-vpn.tld
Endpoint = public-server1.example-vpn.tld:51820
PublicKey = <public key for public-server1.example-vpn.tld>
# routes traffic to itself and entire subnet of peers as bounce server
AllowedIPs = 10.0.0.1/24
PersistentKeepalive = 25
```

## Full Example Code

To run this full example, simply copy the `full wg0.conf config file for node` section from each node onto each server, enable IP forwarding on the public relay, and then start WireGuard on all the machines.

For more detailed instructions, see the [Quickstart](#Quickstart) guide and API reference above. You can also download the complete example setup here: https://github.com/pirate/wireguard-example.

# Further Reading

- https://www.wireguard.com/install/#installation
- https://www.wireguard.com/quickstart/
- https://wiki.debian.org/Wireguard#Configuration
- https://wiki.archlinux.org/index.php/WireGuard
- https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/
- https://jrs-s.net/category/open-source/wireguard/
- https://jrs-s.net/2018/08/05/routing-between-wg-interfaces-with-wireguard/
- https://vincent.bernat.ch/en/blog/2018-route-based-vpn-wireguard
- https://medium.com/@headquartershq/setting-up-wireguard-on-a-mac-8a121bfe9d86
- https://www.linode.com/docs/networking/vpn/set-up-wireguard-vpn-on-ubuntu/
- https://www.stavros.io/posts/how-to-configure-wireguard/
- https://angristan.xyz/how-to-setup-vpn-server-wireguard-nat-ipv6/
- https://www.wireguard.com/netns/
- https://restoreprivacy.com/wireguard/
