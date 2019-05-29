<div align="center">

# The Missing Wireguard Documentation

<img src="https://i.imgur.com/xePt3qp.png"><br/><br/>


API reference guide for Wireguard including Setup, Configuration, and Usage, with examples.


<i>All credit goes to the WireGuard project, [zx2c4](https://www.zx2c4.com/), [Edge Security](https://www.edgesecurity.com/), and the [open source contributors](https://github.com/WireGuard/WireGuard/graphs/contributors) for the original software,<br/> this is my solo unofficial attempt at providing more comprehensive documentation, API references, and examples.</i>

<small>
    
Source for these docs, example code, and issue tracker: https://github.com/pirate/wireguard-docs &nbsp; &nbsp; 
Nicer HTML page version: https://docs.sweeting.me/s/wireguard

</small>

</div>

---

[WireGuard](https://www.wireguard.com/) is a BETA/WIP open-source VPN solution written in C by [Jason Donenfeld](https://www.jasondonenfeld.com) and [others](https://github.com/WireGuard/WireGuard/graphs/contributors), aiming to fix many of the problems that have plagued other modern server-to-server VPN offerings like IPSec/IKEv2, OpenVPN, or L2TP. It shares some similarities with other modern VPN offerings like [Tinc](https://www.tinc-vpn.org/) and [MeshBird](https://github.com/meshbird/meshbird), namely good cipher suites and minimal config.

This is my attempt at writing "The Missing Wireguard Documentation" to make up for the somewhat sparse offical docs on an otherwise great piece of software.

**Official Links**

- Homepage: https://www.wireguard.com
- Install: https://www.wireguard.com/install/
- QuickStart: https://www.wireguard.com/quickstart/
- Main Git repo: https://git.zx2c4.com/WireGuard/
- Github Mirror: https://github.com/WireGuard/WireGuard
- Mailing List: https://lists.zx2c4.com/mailman/listinfo/wireguard

**WireGuard Goals**

 - strong, modern security by default
 - minimal config and key management
 - fast, both low-latency and high-bandwidth
 - simple internals and small protocol surface area
 - simple CLI and seamless integration with system networking
 
<div align="center">
<a href="https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/"><img src="https://www.ckn.io/images/wireguard_comparisions.png" width="600px"/></a><br/><small>
It's also the <i>fast as hell</i>. I get sub 0.5ms pings and 900mbps+ on good connections.<br/>
(See https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/)
</small>
</div>

---

# Table of Contents

See https://github.com/pirate/wireguard-docs for example code and documentation source.

<ul>
<li><a href="#Table-of-Contents">Table of Contents</a></li>
<li><a href="#Intro">Intro</a><ul>
<li><a href="#My-Personal-Requirements-for-a-VPN-Solution">My Personal Requirements for a VPN Solution</a></li>
<li><a href="#List-of-Possible-VPN-Solutions">List of Possible VPN Solutions</a></li>
</ul>
</li>
<li><a href="#Wireguard-Documentation">Wireguard Documentation</a><ul>
<li><a href="#Glossary">Glossary</a><ul>
<li><a href="#PeerNodeDevice">Peer/Node/Device</a></li>
<li><a href="#Bounce-Server">Bounce Server</a></li>
<li><a href="#Subnet">Subnet</a></li>
<li><a href="#CIDR-Notation">CIDR Notation</a></li>
<li><a href="#NAT">NAT</a></li>
<li><a href="#Public-Endpoint">Public Endpoint</a></li>
<li><a href="#Private-key">Private key</a></li>
<li><a href="#Public-key">Public key</a></li>
<li><a href="#DNS">DNS</a></li>
<li><a href="#Example-Strings">Example Strings</a></li>
</ul>
</li>
<li><a href="#How-WireGuard-Works">How WireGuard Works</a><ul>
<li><a href="#How-Public-Relay-Servers-Work">How Public Relay Servers Work</a></li>
<li><a href="#How-WireGuard-Routes-Packets">How WireGuard Routes Packets</a></li>
<li><a href="#What-WireGuard-Traffic-Looks-Like">What WireGuard Traffic Looks Like</a></li>
<li><a href="#WireGuard-Performance">WireGuard Performance</a></li>
<li><a href="#WireGuard-Security-Model">WireGuard Security Model</a></li>
<li><a href="#How-WireGuard-Manages-Keys">How WireGuard Manages Keys</a></li>
</ul>
</li>
<li><a href="#Usage">Usage</a><ul>
<li><a href="#Quickstart">Quickstart</a></li>
<li><a href="#Setup">Setup</a></li>
<li><a href="#Config-Creation">Config Creation</a></li>
<li><a href="#Key-Generation">Key Generation</a></li>
<li><a href="#Start--Stop">Start / Stop</a></li>
<li><a href="#Inspect">Inspect</a></li>
<li><a href="#Testing">Testing</a></li>
</ul>
</li>
<li><a href="#Config-Reference">Config Reference</a><ul>
<li><a href="#Interface">[Interface]</a></li>
<li><a href="#Peer">[Peer]</a></li>
</ul>
</li>
<li><a href="#Advanced-Topics">Advanced Topics</a><ul>
<li><a href="#IPv6">IPv6</a></li>
<li><a href="#Forwarding-All-Traffic">Forwarding All Traffic</a></li>
<li><a href="#Dynamic-IP-Allocation">Dynamic IP Allocation</a></li>
<li><a href="#Other-WireGuard-Implementations">Other WireGuard Implementations</a></li>
<li><a href="#WireGuard-Setup-tools">WireGuard Setup Tools</a></li>
<li><a href="#Config-Shortcuts">Config Shortcuts</a></li>
<li><a href="#Containerization">Containerization</a></li>
</ul>
</li>
</ul>
</li>
<li><a href="#Example-Server-To-Server-Config-with-Roaming-Devices">Example Server-To-Server Config with Roaming Devices</a><ul>
<li><a href="#Overview">Overview</a><ul>
<li><a href="#Network-Topology">Network Topology</a></li>
<li><a href="#Explanation">Explanation</a></li>
<li><a href="#The-Public-Relay">The Public Relay</a></li>
</ul>
</li>
<li><a href="#Full-Example-Code">Full Example Code</a></li>
<li><a href="#Node-Config">Node Config</a><ul>
<li><a href="#public-server1example-vpntld">public-server1.example-vpn.tld</a></li>
<li><a href="#public-server2example-vpndev">public-server2.example-vpn.dev</a></li>
<li><a href="#home-serverexample-vpndev">home-server.example-vpn.dev</a></li>
<li><a href="#laptopexample-vpndev">laptop.example-vpn.dev</a></li>
<li><a href="#phoneexample-vpndev">phone.example-vpn.dev</a></li>
</ul>
</li>
</ul>
</li>
<li><a href="#Further-Reading">Further Reading</a><ul>
<li><a href="#Reference-Docs">Reference Docs</a></li>
<li><a href="#Tutorials">Tutorials</a></li>
<li><a href="#Papers-Articles-and-Talks">Papers, Articles, and Talks</a></li>
<li><a href="#Related-Projects">Related Projects</a></li>
<li><a href="#Docker">Docker</a></li>
<li><a href="#Other">Other</a></li>
<li><a href="#Discussions">Discussions</a></li>
</ul>
</li>
</ul>


# Intro

Over the last 8+ years I've tried a wide range of VPN solutions.  Somewhat out of necessity, since the city I was living in was behind the Great Wall of China.  Everything from old-school PPTP to crazy round-robin GoAgent AppEngine proxy setups were common back in the early 2010's to break through the GFW, these days it's mostly OpenVPN, StealthVPN, IPSec/IKEv2 and others.  From the recommendation of a few people in the [RC](https://recurse.com) Zulip community, I decided to try WireGuard and was surprised to find it checked almost all the boxes.

## My Personal Requirements for a VPN Solution

 - minimal config, low config surface area and few exposed tunables
 - minimal key management overhead, 1 or 2 preshared keys or certs is ok, but ideally not both
 - ability to easily create a LAN like 10.0.0.0/24 between all my servers, every peer can connect to every peer, 
 - ability to bust through NATs with a signalling server, routing nat-to-nat instead of through a relay (webrtc style)
 - fallback to relay server when nat-to-nat busting is unavailable or unreliable
 - ability to route to a fixed list of ips/hosts with 1 keypair per host (not needed, but nice to have: ability to route arbitrary local traffic or *all* internet traffic to a given host)
 - robust automatic reconnects after reboots / network downtime / NAT connection table drops
 - fast (lowest possible latency and line-rate bandwidth)
 - encrypted, and secure by default (not needed, nice to have: short copy-pastable key pairs)
 - ideally support for any type of Level 2 and control traffic, e.g. ARP/DHCP/ICMP (or ideally raw ethernet frames), not just TCP/HTTP
 - ability to join the VPN from Ubuntu, FreeBSD, iOS, macOS (Windows/Android not needed but would be nice
 - not a requirement, but ideally it would support running in docker with a single container, config file, and preshared key on each server, but with a full network interface exposed to the host system (maybe with tun/tap on the host passing traffic to the container, but ideally just a single container + config file without outside dependencies)

## List of Possible VPN Solutions


 - PPTP: ancient, inflexible, insecure, doens't solve all the requirements
 - L2TP: meh
 - SOCKS: proxy tunnel, not a VPN, not great for this use case
 - [IPSec (IKEv2)](https://github.com/jawj/IKEv2-setup)/strongSwan: lots of brittle config that's different for each OS, NAT busting setup is very manual and involves updating the central server and starting all the others in the correct order, not great at reconnecting after network downtime, had to be manually restarted often
 - [TINC](https://www.tinc-vpn.org/): haven't tried it yet, but it doesn't work on iOS, worst case senario I could live with that if it's the only option
 - [OpenVPN](https://openvpn.net/vpn-server-resources/site-to-site-routing-explained-in-detail/): I don't like it from past experience but could be convinced if it's the only option
 - StealthVPN: haven't tried it
 - [MeshBird](https://github.com/meshbird/meshbird): "Cloud native" VPN/networking layer
 - [Algo](https://github.com/trailofbits/algo): haven't tried it yet, should I?
 - [Striesand](https://github.com/StreisandEffect/streisand): haven't tried it yet, whats the best config to try?
 - [SoftEther](https://www.softether.org/): haven't tried it yet, should I?
 - [WireGuard](https://www.wireguard.com/): the subject of this post
 - [ZeroTier](https://www.zerotier.com): haven't tried it yet, sould I?

---

# Wireguard Documentation

---

## Glossary

### Peer/Node/Device

A host that connects to the VPN and has registers a VPN subnet address like 10.0.0.3 for itself. It can also optionally route traffic for more than its own address(es) by specifing subnet ranges in comma-separated CIDR notation.

### Bounce Server

A publicly reachable peer/node that serves as a fallback to relay traffic for other VPN peers behind NATs.  A bounce server is not a special type of server, it's a normal peer just like all the others, the only difference is that it has a public IP and has kernel-level IP forwarding turned on which allows it to bounce traffic back down the VPN to other clients.

### Subnet

A group of IPs separate from the public internet, e.g. 10.0.0.1-255 or 192.168.1.1/24. Generally behind a NAT provided by a router, e.g. in office internet LAN or a home WiFi network.

### CIDR Notation

A way of defining a subnet and its size with a "mask", a smaller mask = more  address bits usable by the subnet & more IPs in the range. Most common ones:
  + `10.0.0.1/32` (a single ip address, `10.0.0.1`) netmask = `255.255.255.255`
  + `10.0.0.1/24` (255 ips from `10.0.0.1`-`255`) netmask = ` 255.255.255.0`
  + `10.0.0.1/16` (65,536 ips from `10.0.0.0` - `10.0.255.255`) netmask = `255.255.0.0`
  + `10.0.0.1/8` (16,777,216 ips from `10.0.0.0` - `10.255.255.255`) netmask = `255.0.0.0`
  + `0.0.0.1/0` (4,294,967,296 ips from `0.0.0.0` - `255.255.255.255`) netmask = `0.0.0.0`
  + IPv6 CIDR notation is also supported e.g. `fd42:42:42::1/64`
 
https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing

To people just getting started `10.0.0.1/32` may seem like a weird and confusing way to refer to a single IP.  This design is nice though because it allows peers to expose multiple IPs if needed without needing multiple notations.  Just know that anywhere you see something like `10.0.0.3/32`, it really just means `10.0.0.3`.

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

### Example Strings

`example-vpn.dev`, `public-server1`, `public-server2`, `home-server`, `laptop`, `phone`

These are demo host and domain names used in the example config.
Replace them with your own names when doing your actual setup.

---

## How WireGuard Works

### How Public Relay Servers Work

Public relays are just normal VPN peers that are able to act as an intermediate relay server between any VPN clients behind NATs, they can forward any VPN subnet traffic they receives to the correct peer at the system level (WireGuard doesn't care how this happens, it's handled by the kernel `net.ipv4.ip_forward = 1` and the iptables routing rules).

If all peers are publicly accessible, you don't have to worry about special treatment to make one of them a relay server, it's only needed if you have any peers connecting from behind a NAT.

Each client only needs to define the publicly accessible servers/peers in it's config, any traffic bound to other peers behind NATs will go to the catchall VPN subnet (e.g. `10.0.0.1/24`) in the public relays `AllowedIPs` route and will be forwarded accordingly once it hits the relay server.

In summary: only direct connections between clients should be configured, any connections that need to be bounced should not be defined as peers, as they should head to the bounce server first and be routed from there back down the vpn to the correct client.

### How WireGuard Routes Packets

More complex topologies are definitely achievable, but these are the basic routing methods used in typical WireGuard setups:

- **Direct node-to-node**
  In the best case, the nodes are on the same LAN or are both publicly accessible, and traffic will route over encrypted UDP packets sent directly between the nodes.
- **Node behind local NAT to public node**
  When 1 of the 2 parties is behind a remote NAT (e.g. when laptop behind a NAT connects to `public-server2`), the connection will be opened from NAT -> public client, then traffic will route directly between them in both directions as long as the connection is kept alive.
- **Node behind local NAT to node behind remote NAT (via relay)**
  In the worst case when both parties are behind remote NATs, both will open a connection to `public-server1`, and traffic will forward through the intermediary bounce server as long as the connections are kept alive.
- **Node behind local NAT to node behind remote NAT (via NAT-busting)**
I'm not sure if Wireguard supports this method yet, but it's definitely possible in theory, see: [WebRTC](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API), [N2N](https://www.ntop.org/products/n2n/), [Pwnat](https://samy.pl/pwnat/). A readily available signaling server like`public-server1` should make connection establishment and handoff relatively easy, but ICMP packet trickery can also be used. Please let me know if WireGuard does this via [Github Issue](https://github.com/pirate/wireguard-docs/issues).


Chosing the proper routing method is handled automatically by WireGuard as long as at least one server is acting as a public relay with `net.ipv4.ip_forward = 1` enabled, and clients have `AllowIPs = 10.0.0.1/24` set in the relay server `[peer]` (to take traffic for the whole subnet).

More specific (also usually more direct) routes provided by other peers will take precedence when available, otherwise traffic will fall back to the least specific route and use the `10.0.0.1/24` catchall to forward traffic to the bounce server, where it will in turn be routed by the relay server's system routing table back down the VPN to the specific peer thats accepting routes for that traffic.

You can figure out which routing method WireGuard is using for a given address by measuring the ping times to figure out the unique length of each hop, and by inspecting the output of:
```bash
wg show wg0
```

### What WireGuard Traffic Looks Like

WireGuard uses encrypted UDP packets for all traffic, it does not provice guarantees around packet delivery or ordering, as that is handled by TCP connections within the encrypted tunnel.

<img src="https://github.com/Lekensteyn/wireguard-dissector/raw/master/wireshark-wg.png" width="400px"/><br/>

Further reading:

- https://www.wireshark.org/docs/dfref/w/wg.html
- https://github.com/Lekensteyn/wireguard-dissector
- https://nbsoftsolutions.com/blog/viewing-wireguard-traffic-with-tcpdump

### WireGuard Performance

WireGuard claims faster performance than most other competing VPN solutions, though the exact numbers are sometimes debated and may depend on whether hardware-level acceleration is available for certain cryptographic ciphers.

WireGuard's performance gains are achieved by handling routing at the kernel level, and by using modern cipher suites running on all cores to encrypt traffic. WireGuard also gains a significant advantage by using UDP with no delivery/ordering guarantees (compared to VPNs that run over TCP or implement their own guaranteed delivery mechanisms).

<img src="https://i.imgur.com/heEYg59.png" width="400px"/>


Futher reading:

- https://www.wireguard.com/performance/
- https://www.reddit.com/r/linux/comments/9bnowo/wireguard_benchmark_between_two_servers_with_10/
- https://restoreprivacy.com/openvpn-ipsec-wireguard-l2tp-ikev2-protocols/


### WireGuard Security Model

WireGuard uses the following protocols and primitives to secure traffic:

- ChaCha20 for symmetric encryption, authenticated with Poly1305, using RFC7539’s AEAD construction
- Curve25519 for ECDH
- BLAKE2s for hashing and keyed hashing, described in RFC7693
- SipHash24 for hashtable keys
- HKDF for key derivation, as described in RFC5869

> WireGuard's cryptography is essentially an instantiation of Trevor Perrin's Noise framework. It's modern and, again, simple. Every other VPN option is a mess of negotiation and handshaking and complicated state machines. WireGuard is like the Signal/Axolotl of VPNs, except it's much simpler and easier to reason about (cryptographically, in this case) than double ratchet messaging protocols.
> It is basically the qmail of VPN software.
> And it's ~4000 lines of code. It is plural orders of magnitude smaller than its competitors.
> 
https://news.ycombinator.com/item?id=14599834

Further reading:

- https://www.wireguard.com/papers/wireguard.pdf
- https://eprint.iacr.org/2018/080.pdf
- https://courses.csail.mit.edu/6.857/2018/project/He-Xu-Xu-WireGuard.pdf
- https://www.wireguard.com/talks/blackhat2018-slides.pdf
- https://arstechnica.com/gadgets/2018/08/wireguard-vpn-review-fast-connections-amaze-but-windows-support-needs-to-happen/


### How WireGuard Manages Keys

Authentication in both directions is achieved with a simple public/private keypair for each peer. Each peer generates these keys during the setup phase, and shares only the public key with other peers.

No other certificates or preshared keys are needed beyond the public/private keys for each node.

Key generation, distribution, and revokation can be handled in larger deployments using a separate service like Ansible or Kubernetes Secrets.

Some services that help with key distribution and deployment:

- https://pypi.org/project/wireguard-p2p/
- https://github.com/trailofbits/algo
- https://github.com/StreisandEffect/streisand
- https://github.com/its0x08/wg-install

You can also read in keys from a file or via command if you don't want to hardcode them in `wg0.conf`, this makes managing keys via 3rd party service much easier:

```ini
[Interface]
...
PostUp = wg set %i private-key /etc/wireguard/wg0.key <(cat /some/path/%i/privkey)
```
---

## Usage

### Quickstart

Overview of the general process:

1. Install `apt install wireguard` or `pkg/brew install wireguard-tools` on each node
2. Generate public and private keys locally on each node `wg genkey`+`wg pubkey`
3. Create a `wg0.conf` wireguard config file on the main relay server
    - `[Interface]` Make sure to specify a CIDR range for the entire VPN subnet when defining the address the server accepts routes for `Address = 10.0.0.1/24`
    - `[Peer]` Create a peer section for every client joining the VPN, using their corresponding remote public keys
4. Crete a `wg0.conf` on each client node
   - `[Interface]` Make sure to specify only a single IP for client peers that don't relay traffic `Address = 10.0.0.3/32`.
   - `[Peer]` Create a peer section for each public peer not behind a NAT, make sure to specify a CIDR range for the entire VPN subnet when defining the remote peer acting as the bounce server `AllowedIPs = 10.0.0.1/24`. Make sure to specify individual IPs for remote peers that don't relay traffic and only act as simple clients `AllowedIPs = 10.0.0.3/32`.
5. Start wireguard on the main relay server with `wg-quick up /full/path/to/wg0.conf`
6. Start wireguard on all the client peers with `wg-quick up /full/path/to/wg0.conf`
7. Traffic is routed from peer to peer using most optimal route over the WireGuard interface, e.g. `ping 10.0.0.3` checks for local direct route first, then checks for route via public internet, then finally tries to route by bouncing through the public relay server.

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

```bash
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
# Note: you must specify the absolute path to wg0.conf, relative paths wont work
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
# install iperf using your preferred package manager
apt/brew/pkg install iperf

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

#### DNS

Check for DNS leaks using http://dnsleak.com, or by checking the resolver on a lookup:
```bash
dig example.com A
```

---

## Config Reference


**Jump to definition:**

¶ <a href="#Interface">`[Inteface]`</a>  
¶ <a href="#-Name">`# Name = node1.example.tld`</a>  
¶ <a href="#Address">`Address = 10.0.0.3/32`</a>  
¶ <a href="#ListenPort">`ListenPort = 51820`</a>  
¶ <a href="#PrivateKey">`PrivateKey = localPrivateKeyAbcAbcAbc=`</a>  
¶ <a href="#DNS">`DNS = 1.1.1.1,8.8.8.8`</a>  
¶ <a href="#Table">`Table = 12345`</a>  
¶ <a href="#MTU">`MTU = 1500`</a>  
¶ <a href="#PreUp">`PreUp = /bin/example arg1 arg2 %i`</a>  
¶ <a href="#PostUp">`PostUp = /bin/example arg1 arg2 %i`</a>  
¶ <a href="#PreDown">`PreDown = /bin/example arg1 arg2 %i`</a>  
¶ <a href="#PostDown">`PostDown = /bin/example arg1 arg2 %i`</a>  


¶ <a href="#Peer-">`[Peer]`</a>  
¶ <a href="#-Name1">`# Name = node2-node.example.tld`</a>  
¶ <a href="#AllowedIPs">`AllowedIPs = 10.0.0.1/24`</a>  
¶ <a href="#ListenPort">`Endpoint = node1.example.tld:51820`</a>  
¶ <a href="#PublicKey">`PublicKey = remotePublicKeyAbcAbcAbc=`</a>  
¶ <a href="#PersistentKeepalive">`PersistentKeepalive = 25`</a>  

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


#### `Table`

Optionally defines which routing table to use for the WireGuard routes, not necessary to configure for most setups.

There are two special values: ‘off’ disables the creation of routes altogether, and ‘auto’ (the default) adds routes to the default table and enables special handling of default routes.

https://git.zx2c4.com/WireGuard/about/src/tools/man/wg-quick.8

**Examples**

```ini
Table = 1234
```


#### `MTU`

Optionally defines the maximum transmission unit (MTU, aka packet/frame size) to use when connecting to the peer, not necessary to configure for most setups.

The MTU is automatically determined from the endpoint addresses or the system default route, which is usually a sane choice.

There are two special values: ‘off’ disables the creation of routes altogether, and ‘auto’ (the default) adds routes to the default table and enables special handling of default routes.

https://git.zx2c4.com/WireGuard/about/src/tools/man/wg-quick.8

**Examples**

```ini
MTU = 1500
```


#### `PreUp`

Optionally run a command before the interface is brought up.

**Examples**

* Add an ip route
`PreUp = ip rule add ipproto tcp dport 22 table 1234`

#### `PostUp`

Optionally run a command after the interface is brought up.

**Examples**

* Read in a config value from a file or some command's output
`PostUp = wg set %i private-key /etc/wireguard/wg0.key <(some command here)`

* Log a line to a file
`PostUp = echo "$(date +%s) WireGuard Started" >> /var/log/wireguard.log`

* Hit a webhook on another server
`PostUp = curl https://events.example.dev/wireguard/started/?key=abcdefg`

* Add an route to the system routing table
`PostUp = ip rule add ipproto tcp dport 22 table 1234`

* Add an iptables rule to enable packet forwarding on the WireGuard interface
`PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE`

#### `PreDown`

Optionally run a command before the interface is brought down.

**Examples**

* Log a line to a file
`PostDown = echo "$(date +%s) WireGuard Going Down" >> /var/log/wireguard.log`

* Hit a webhook on another server
`PostDown = curl https://events.example.dev/wireguard/stopping/?key=abcdefg`


#### `PostDown`

Optionally run a command after the interface is brought down.

**Examples**

* Log a line to a file
`PostDown = echo "$(date +%s) WireGuard Stopped" >> /var/log/wireguard.log`

* Hit a webhook on another server
`PostDown = curl https://events.example.dev/wireguard/stopped/?key=abcdefg`

* Remove the iptables rule that forwards packets on the WireGuard interface
`PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE`


### `[Peer]`

Defines the VPN settings for a remote peer capable of routing traffic for one or more addresses (itself and/or other peers). Peers can be either a public bounce server that relays traffic to other peers, a directly accessible client via lan/internet that is not behind a NAT and only routes traffic for itself.

All clients must be defined as peers on the public bounce server, however on the simple clients that only route traffic for themselves, only the public relay and other directly accessible nodes need to be defined as peeers. Nodes that are behind separate NATs should not be defined as peers outside of the public server config, as no specific direct route is available between separate NATs. Instead, nodes behind NATs should only define the public relay servers and other public clients as their peers, and should specify `AllowedIPs = 10.0.0.1/24` on the public server that accept routes and bounce traffic to the remote NAT-ed peers.

In summary, all nodes must be defined on the main bounce server.  On client servers, only peers that are directly accessible from a node should be defined as peers of that node, any peers that must be relayed by a bounce sherver should be left out and will be handled by the relay server's catchall route.

In the configuration outlined in the docs below, a single server `public-server1` acts as the relay bounce server for a mix of publicly accessible and NAT-ed clients, and peers are configured on each node accordingly:

- **in `public-server1` `wg0.conf` (bounce server)**
  `[peer]` list: `public-server2`, `home-server`, `laptop`, `phone`

- **in `public-server2` `wg0.conf` (simple public client)**
  `[peer]` list: `public-server1`

- **in `home-server` `wg0.conf` (simple client behind nat)**
  `[peer]` list: `public-server1`, `public-server2`

- **in `laptop` `wg0.conf` (simple client behind nat)**
  `[peer]` list: `public-server1`, `public-server2`

- **in `phone` `wg0.conf` (simple client behind nat)**
  `[peer]` list: `public-server1`, `public-server2`

**Examples**

 - Peer is a simple public client that only routes traffic for itself
```ini
[Peer]
# Name = public-server2.example-vpn.dev
Endpoint = public-server2.example-vpn.dev:51820
PublicKey = <public key for public-server2.example-vpn.dev>
AllowedIPs = 10.0.0.2/32
```

 - Peer is a simple client behind a NAT that only routes traffic for itself
```ini
[Peer]
# Name = home-server.example-vpn.dev
Endpoint = home-server.example-vpn.dev:51820
PublicKey = <public key for home-server.example-vpn.dev>
AllowedIPs = 10.0.0.3/32
```

 - Peer is a public bounce server that can relay traffic to other peers
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

 - Endpoint is an IP address
`Endpoint = 123.124.125.126:51820`  (IPv6 is also supported)
 - Endpoint is a hostname/FQDN
`Endpoint = public-server1.example-vpn.tld:51820`

#### `AllowedIPs`

This defines the IP ranges that a peer will route traffic for. Usually this is a single address (the VPN address of the peer itself), but for bounce servers this will be a range of the IPs or subnets that the relay server is capable of routing traffic for.  Using comma-separated IPv4 or IPv6 CIDR notation, a single address can be defined as routable, or multiple ranges of IPs all the way up to `0.0.0.0/0` to route all internet and VPN traffic through that peer.

When deciding how to route a packet, the system chooses the most specific route first, and falls back to broader routes. So for a packet destined to `10.0.0.3`, the system would first look for a peer advertising `10.0.0.3/32` specifically, and would fall back to a peer advertising `10.0.0.1/24` or a larger range like `0.0.0.0/0` as a last resort.

**Examples**


 - peer is a simple client that only accepts traffic to/from itself
`AllowedIPs = 10.0.0.3/32`

 - peer is a relay server that can bounce VPN traffic to all other peers
`AllowedIPs = 10.0.0.1/24`

 - peer is a relay server that bounces all internet & VPN traffic (like a proxy), including IPv6
`AllowedIPs = 0.0.0.0/0,::/0`

 - peer is a relay server that routes to itself and only one other peer
`AllowedIPs = 10.0.0.3/32,10.0.0.4/32`

 - peer is a relay server that routes to itself and all nodes on its local LAN
`AllowedIPs = 10.0.0.3/32,192.168.1.1/24`

#### `PublicKey`

This is the public key for the remote node, sharable with all peers.
All nodes must have a public key set, regardless of whether they are public bounce servers relaying traffic, or simple clients joining the VPN.

This key can be generated with `wg pubkey < example.key > example.key.pub`.
(see above for how to generate the private key `example.key`)

**Examples**

`PublicKey = somePublicKeyAbcdAbcdAbcdAbcd=`

#### `PersistentKeepalive`

If the connection is going from a NAT-ed peer to a public peer, the node behind the NAT must regularly send an outgoing ping in order to keep the bidirectional connection alive in the NAT router's connection table.

**Examples**

 - local public node to remote public node
  This value should be left undefined as persistent pings are not needed.
  
 - local public node to remote NAT-ed node
  This value should be left undefined as it's the client's responsibility to keep the connection alive because the server cannot reopen a dead connection to the client if it times out.
  
 - local NAT-ed node to remote public node
`PersistentKeepalive = 25` this will send a ping to every 25 seconds keeping the connection open in the local NAT router's connection table.

---

## Advanced Topics

### IPv6

The examples in these docs primarily use IPv4, but Wireguard natively supports IPv6 CIDR notation and addresses everywhere that it supports IPv4, simply add them as you would any other subnet range or address.

**Example**

```ini
[Interface]
AllowedIps = 10.0.0.3/24, fd42:42:42::1/64

[Peer]
...
AllowedIPs = 0.0.0.0/0, ::/0
```

### Forwarding All Traffic

If you want to forward *all* internet traffic through the VPN, and not just use it as a server-to-server subnet, you can add `0.0.0.0/0, ::/0` to the `AllowedIPs` definition of the peer you want to pipe your traffic through.

**Example**

```ini
[Interface]
# Name = phone.example-vpn.dev
Address = 10.0.0.3/32
PrivateKey = <private key for phone.example-vpn.dev>

[Peer]
# Name = public-server1.example-vpn.dev
PublicKey = <public key for public-server1.example-vpn.dev>
Endpoint = public-server1.example-vpn.dev:51820
AllowedIPs = 0.0.0.0/0, ::/0
```

### Dynamic IP Allocation

Dynamic allocation of IPs (instead of only having fixed peers) is being developed, the WIP implmentation is available here:
https://github.com/WireGuard/wg-dynamic

You can also build a dynamic allocation system yourself by reading in IP values from files at runtime by using `PostUp` (see below).

**Example**
```ini
[Interface]
...
PostUp = PostUp = wg set %i allowed-ips /etc/wireguard/wg0.key <(some command)
```

### Other WireGuard Implementations


- https://git.zx2c4.com/wireguard-go/about/  
A compliant userland WireGuard implementation written in Go.

- https://github.com/cloudflare/boringtun  
A compliant WireGuard implementation with the exact same API, written in Rust.
See https://blog.cloudflare.com/boringtun-userspace-wireguard-rust/


Both of these are slower than the native C version that runs in kernel land, but provide other benefits by running in userland (e.g. easier containerization).

### WireGuard Setup Tools

These are some GUI and CLI tools that wrap WireGuard to assist with config, deployment, key management, and connection.

 - https://github.com/subspacecloud/subspace
 - https://github.com/corrad1nho/qomui
 - https://github.com/max-moser/network-manager-wireguard
 - https://github.com/its0x08/wg-install
 - https://pypi.org/project/wireguard-p2p/
 - https://github.com/trailofbits/algo
 - https://github.com/StreisandEffect/streisand


### Config Shortcuts

Credit for these shortcuts goes to: 
https://www.ericlight.com/new-things-i-didnt-know-about-wireguard.html

#### Sharing a single peers.conf file

WireGuard will ignore a peer whose public key matches the interface's private key. So you can distribute a single list of peers everywhere, and only define the `[Inteface]` separately on each server.

See: https://lists.zx2c4.com/pipermail/wireguard/2018-December/003703.html:

You can combine this with `wg addconf` like this:

Each peer has its own `/etc/wireguard/wg0.conf` file, which only contains it's `[Interface]` section.

Each peer also has a shared `/etc/wireguard/peers.conf` file, which contains all the peers.

The `wg0.conf` file also has a `PostUp` hook, calling `wg addconf /etc/wireguard/peers.conf`.

It's up to you to decide how you want to share the `peers.conf`, be it via a proper orchestration platform, something much more pedestrian like Dropbox, or something kinda wild like Ceph. I dunno, but it's pretty great that you can just wildly fling a peer section around, without worrying whether it's the same as the interface.

#### Setting config values from files or command outputs

You can set config values from arbitrary commands or by reading in values from files, this makes key management and deployment much easier as you can read in keys at runtime from a 3rd party service like Kubernetes Secrets or AWS KMS.

See: https://lists.zx2c4.com/pipermail/wireguard/2018-December/003702.html

**Example**

You can read in a file as the `PrivateKey` by doing something like:

`PostUp = wg set %i private-key /etc/wireguard/wg0.key <(some command)`


### Containerization

WireGuard can be run in Docker with varying degrees of ease. In the simplest case, `--privileged` and `--cap-add=all` args can be added to the docker commands to enable the loading of the kernel module.

Setups can get somewhat complex are are highly dependent on what you're trying to achieve. You can have WireGuard itself run in a container and expose a network interface to the host, or you can have WireGuard running on the host exposing an interface to specific containers.

**Further Reading**

- https://www.wireguard.com/#ready-for-containers
- https://medium.com/@mdp/securing-docker-with-wireguard-82ad45004f4d
- https://blog.jessfraz.com/post/installing-and-using-wireguard/
- https://github.com/cmulk/wireguard-docker
- https://github.com/activeeos/wireguard-docker
- https://github.com/ironhalik/docker-wireguard
- https://nbsoftsolutions.com/blog/routing-select-docker-containers-through-wireguard-vpn

---

# Example Server-To-Server Config with Roaming Devices

The complete example config for the setup below can be found here: https://github.com/pirate/wireguard-docs/tree/master/full-example (WARNING: do not use it on your devices without chaning the public/private keys!).

## Overview

### Network Topology

These 5 devices are used in our example setup to explain how WireGuard supports bridging across a variety of network conditions, they're all under an example domain `example-vpn.dev`, with the following short hostnames:

- `public-server1` (not behind a NAT, acts as the main VPN bounce server)
- `public-server2` (not behind a NAT, joins as a peer without bouncing traffic)
- `home-server` (behind a NAT, joins as a peer without bouncing traffic)
- `laptop` (behind NAT, sometimes shared w/ home-server/phone, sometimes roaming)
- `phone` (behind NAT, sometimes shared w/ home-server/laptop, sometimes roaming)

### Explanation

This VPN config simulates setting up a small VPN subnet `10.0.0.1/24` shared by 5 nodes. Two of the nodes (public-server1 and public-server2) are VPS instances living in a cloud somewhere, with public IPs accessible to the internet.  home-server is a stationary node that lives behind a NAT with a dynamic IP, but it doesn't change frequently. Phone and laptop are both roaming nodes, that can either be at home in the same LAN as home-server, or out-and-about using public wifi or cell service to connect to the VPN.

Whenever possible, nodes should connect directly to eachother, depending on whether nodes are directly accessible or NATs are between them, traffic will route accordinly:

### The Public Relay

`public-server1` acts as an intermediate relay server between any VPN clients behind NATs, it will forward any 10.0.0.1/24 traffic it receives to the correct peer at the system level (WireGuard doesn't care how this happens, it's handled by the kernel `net.ipv4.ip_forward = 1` and the iptables routing rules).

Each client only needs to define the publicly accessible servers/peers in it's config, any traffic bound to other peers behind NATs will go to the catchall `10.0.0.1/24` for the server and will be forwarded accordingly once it hits the main server.

In summary: only direct connections between clients should be configured, any connections that need to be bounced should not be defined as peers, as they should head to the bounce server first and be routed from there back down the vpn to the correct client.

## Full Example Code

To run this full example, simply copy the `full wg0.conf config file for node` section from each node onto each server, enable IP forwarding on the public relay, and then start WireGuard on all the machines.

For more detailed instructions, see the [Quickstart](#Quickstart) guide and API reference above. You can also download the complete example setup here: https://github.com/pirate/wireguard-docs/tree/master/full-example (WARNING: do not use it on your devices without chaning the public/private keys!).

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

---

# Further Reading

### Reference Docs

- https://www.wireguard.com/install/#installation
- https://git.zx2c4.com/WireGuard/about/src/tools/man/wg.8
- https://git.zx2c4.com/WireGuard/about/src/tools/man/wg-quick.8
- https://wiki.archlinux.org/index.php/WireGuard
- https://wiki.debian.org/Wireguard#Configuration

### Tutorials

- https://www.wireguard.com/quickstart/
- https://www.stavros.io/posts/how-to-configure-wireguard/
- https://nbsoftsolutions.com/blog/wireguard-vpn-walkthrough
- https://proprivacy.com/guides/wireguard-hands-on-guide
- https://angristan.xyz/how-to-setup-vpn-server-wireguard-nat-ipv6/
- https://medium.com/@headquartershq/setting-up-wireguard-on-a-mac-8a121bfe9d86
- https://grh.am/2018/wireguard-setup-guide-for-ios/
- https://techcrunch.com/2018/07/28/how-i-made-my-own-wireguard-vpn-server/
- https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/
- https://jrs-s.net/2018/08/05/routing-between-wg-interfaces-with-wireguard/
- https://www.stavros.io/posts/how-to-configure-wireguard/
- https://vincent.bernat.ch/en/blog/2018-route-based-vpn-wireguard
- https://try.popho.be/wg.html
- https://www.ericlight.com/wireguard-part-one-installation.html
- https://www.ericlight.com/wireguard-part-two-vpn-routing.html
- https://www.ericlight.com/wireguard-part-three-troubleshooting.html

### Papers, Articles, and Talks

- https://www.wireguard.com/papers/wireguard.pdf
- https://www.wireguard.com/presentations/
- https://eprint.iacr.org/2018/080.pdf
- https://courses.csail.mit.edu/6.857/2018/project/He-Xu-Xu-WireGuard.pdf
- https://arstechnica.com/gadgets/2018/08/wireguard-vpn-review-fast-connections-amaze-but-windows-support-needs-to-happen/
- https://www.wireguard.com/talks/blackhat2018-slides.pdf

### Related Projects

- https://github.com/subspacecloud/subspace
- https://github.com/trailofbits/algo
- https://github.com/StreisandEffect/streisand
- https://github.com/its0x08/wg-install
- https://pypi.org/project/wireguard-p2p/
- https://github.com/cloudflare/boringtun
- https://git.zx2c4.com/wireguard-go/about/
- https://github.com/WireGuard/wg-dynamic
- https://github.com/WireGuard/wireguard-ios
- https://github.com/WireGuard/wireguard-windows
- https://github.com/WireGuard/wireguard-rs
- https://github.com/WireGuard/wireguard-go

### Docker

- https://www.wireguard.com/#ready-for-containers
- https://medium.com/@mdp/securing-docker-with-wireguard-82ad45004f4d
- https://blog.jessfraz.com/post/installing-and-using-wireguard/
- https://nbsoftsolutions.com/blog/leaning-on-algo-to-route-docker-traffic-through-wireguard
- https://github.com/cmulk/wireguard-docker
- https://github.com/activeeos/wireguard-docker
- https://github.com/ironhalik/docker-wireguard
- https://nbsoftsolutions.com/blog/routing-select-docker-containers-through-wireguard-vpn
- https://www.net.in.tum.de/fileadmin/bibtex/publications/theses/2018-pudelko-vpn-performance.pdf


### Other

- https://blog.cloudflare.com/boringtun-userspace-wireguard-rust/
- https://jrs-s.net/category/open-source/wireguard/
- https://restoreprivacy.com/openvpn-ipsec-wireguard-l2tp-ikev2-protocols/
- https://restoreprivacy.com/wireguard/
- https://www.ericlight.com/new-things-i-didnt-know-about-wireguard.html
- https://www.ericlight.com/tag/wireguard.html
- https://www.linode.com/docs/networking/vpn/set-up-wireguard-vpn-on-ubuntu/
- https://www.reddit.com/r/linux/comments/9bnowo/wireguard_benchmark_between_two_servers_with_10/
- https://www.wireguard.com/netns/
- https://www.wireguard.com/performance/
- https://blogs.gnome.org/thaller/2019/03/15/wireguard-in-networkmanager/
- https://github.com/max-moser/network-manager-wireguard


### Discussions

- https://www.reddit.com/r/WireGuard
- https://lists.zx2c4.com/mailman/listinfo/wireguard
- https://www.reddit.com/r/VPN/comments/a914mr/can_you_explain_the_difference_between_openvpn/
- https://www.reddit.com/r/WireGuard/comments/b0m5g2/ipv6_leaks_psa_for_anyone_here_using_wireguard_to/?utm_source=reddit&utm_medium=usertext&utm_name=WireGuard&utm_content=t1_ep8tv0o
- https://www.reddit.com/r/VPN/comments/au4owb/how_secure_is_wireguard_vpn_protocol/
- https://www.reddit.com/r/WireGuard/comments/ap33df/wireguard_what_is_so_special_about_it_and_why/
- https://www.reddit.com/r/VPN/comments/9hgs2x/what_is_the_difference_between_wireguard_openvpn/
- https://www.reddit.com/r/privacytoolsIO/comments/8l0vxt/what_do_you_think_guys_of_wireguard/
- https://news.ycombinator.com/item?id=20036194
- https://news.ycombinator.com/item?id=17659983
- https://news.ycombinator.com/item?id=17846387

For more detailed instructions, see the [Quickstart](#Quickstart) guide and API reference above. You can also download the complete example setup here: https://github.com/pirate/wireguard-example.


---

<center>
    
Suggest changes: https://github.com/pirate/wireguard-docs/issues
    
</center>
