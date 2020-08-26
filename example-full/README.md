# Example Server-To-Server Config with Roaming Devices

WARNING: **Make sure to change the IP addresses and ranges in your configs before running!**
The blocks used in these examples are reserved for documentation purposes by the IETF and should never be used in real network setups.

 - **`192.0.2.0/24`** (TEST-NET-1) IPv4 example range [RFC5737](https://tools.ietf.org/html/rfc5737)
 - **`2001:DB8::/32`** IPv6 example range [RFC3849](https://tools.ietf.org/html/rfc3849)

You can use any private range you want instead, e.g. `10.0.44.0/24`, just make sure
it doesn't conflict with any of the LAN subnet ranges your peers are on.

The complete example config for the setup below can be found here: https://github.com/pirate/wireguard-docs/tree/master/full-example (WARNING: do not use it on your devices without changing the public/private keys!).

## Overview

### Network Topology

These 5 devices are used in our example setup to explain how WireGuard supports bridging across a variety of network conditions, they're all under an example domain `example-vpn.dev`, with the following short hostnames:

- `public-server1` (not behind a NAT, acts as the main VPN bounce server)
- `public-server2` (not behind a NAT, joins as a peer without bouncing traffic)
- `home-server` (behind a NAT, joins as a peer without bouncing traffic)
- `laptop` (behind NAT, sometimes shared w/ home-server/phone, sometimes roaming)
- `phone` (behind NAT, sometimes shared w/ home-server/laptop, sometimes roaming)

### Explanation

This VPN config simulates setting up a small VPN subnet `192.0.2.1/24` shared by 5 nodes. Two of the nodes (public-server1 and public-server2) are VPS instances living in a cloud somewhere, with public IPs accessible to the internet.  home-server is a stationary node that lives behind a NAT with a dynamic IP, but it doesn't change frequently. Phone and laptop are both roaming nodes, that can either be at home in the same LAN as home-server, or out-and-about using public wifi or cell service to connect to the VPN.

Whenever possible, nodes should connect directly to each other, depending on whether nodes are directly accessible or NATs are between them, traffic will route accordingly:

### The Public Relay

`public-server1` acts as an intermediate relay server between any VPN clients behind NATs, it will forward any 192.0.2.1/24 traffic it receives to the correct peer at the system level (WireGuard doesn't care how this happens, it's handled by the kernel `net.ipv4.ip_forward = 1` and the iptables routing rules).

Each client only needs to define the publicly accessible servers/peers in its config, any traffic bound to other peers behind NATs will go to the catchall `192.0.2.1/24` for the server and will be forwarded accordingly once it hits the main server.

In summary: only direct connections between clients should be configured, any connections that need to be bounced should not be defined as peers, as they should head to the bounce server first and be routed from there back down the vpn to the correct client.

## Full Example Code

To run this full example, simply copy the `full wg0.conf config file for node` section from each node onto each server, enable IP forwarding on the public relay, and then start WireGuard on all the machines.

For more detailed instructions, see the [Quickstart](#Quickstart) guide and API reference above. You can also download the complete example setup here: https://github.com/pirate/wireguard-docs/tree/master/full-example (WARNING: do not use it on your devices without changing the public/private keys!).

## Node Config

### public-server1.example-vpn.tld
 * public endpoint: `public-server1.example-vpn.tld:51820` 
 * own vpn ip address: `192.0.2.1`
 * can accept traffic for ips: `192.0.2.1/24`
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
AllowedIPs = 192.0.2.1/24
PersistentKeepalive = 25
```
 * config as local interface:
```ini
[Interface]
# Name = public-server1.example-vpn.tld
Address = 192.0.2.1/24
ListenPort = 51820
PrivateKey = <private key for public-server1.example-vpn.tld>
DNS = 1.1.1.1
```
 * peers: public-server2, home-server, laptop, phone
 * full `wg0.conf` config file for node:
```ini
[Interface]
# Name = public-server1.example-vpn.tld
Address = 192.0.2.1/24
ListenPort = 51820
PrivateKey = <private key for public-server1.example-vpn.tld>
DNS = 1.1.1.1

[Peer]
# Name = public-server2.example-vpn.dev
Endpoint = public-server2.example-vpn.dev:51820
PublicKey = <public key for public-server2.example-vpn.dev>
AllowedIPs = 192.0.2.2/32

[Peer]
# Name = home-server.example-vpn.dev
Endpoint = home-server.example-vpn.dev:51820
PublicKey = <public key for home-server.example-vpn.dev>
AllowedIPs = 192.0.2.3/32

[Peer]
# Name = laptop.example-vpn.dev
PublicKey = <public key for laptop.example-vpn.dev>
AllowedIPs = 192.0.2.4/32

[Peer]
# phone.example-vpn.dev
PublicKey = <public key for phone.example-vpn.dev>
AllowedIPs = 192.0.2.5/32
```

### public-server2.example-vpn.dev
 * public endpoint: `public-server2.example-vpn.dev:51820` 
 * own vpn ip address: `192.0.2.2`
 * can accept traffic for ips: `192.0.2.2/32`
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
Address = 192.0.2.2/32
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
AllowedIPs = 192.0.2.2/32
```
 * peers: public-server1
 * full `wg0.conf` config file for node:
```ini
[Interface]
# Name = public-server2.example-vpn.dev
Address = 192.0.2.2/32
ListenPort = 51820
PrivateKey = <private key for public-server2.example-vpn.dev>
DNS = 1.1.1.1

[Peer]
# Name = public-server1.example-vpn.tld
Endpoint = public-server1.example-vpn.tld:51820
PublicKey = <public key for public-server1.example-vpn.tld>
# routes traffic to itself and entire subnet of peers as bounce server
AllowedIPs = 192.0.2.1/24
PersistentKeepalive = 25
```

### home-server.example-vpn.dev
 * public endpoint: (none, behind NAT)
 * own vpn ip address: `192.0.2.3`
 * can accept traffic for ips: `192.0.2.3/32`
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
Address = 192.0.2.3/32
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
AllowedIPs = 192.0.2.3/32
```
 * peers: public-server1
 * full `wg0.conf` config file for node:
```ini
[Interface]
# Name = home-server.example-vpn.dev
Address = 192.0.2.3/32
ListenPort = 51820
PrivateKey = <private key for home-server.example-vpn.dev>
DNS = 1.1.1.1

[Peer]
# Name = public-server1.example-vpn.tld
Endpoint = public-server1.example-vpn.tld:51820
PublicKey = <public key for public-server1.example-vpn.tld>
# routes traffic to itself and entire subnet of peers as bounce server
AllowedIPs = 192.0.2.1/24
PersistentKeepalive = 25
```

### laptop.example-vpn.dev
 * public endpoint: (none, behind NAT)
 * own vpn ip address: `192.0.2.4`
 * can accept traffic for ips: `192.0.2.4/32`
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
Address = 192.0.2.4/32
PrivateKey = <private key for laptop.example-vpn.dev>
DNS = 1.1.1.1
```
 * config as peer:
```ini
[Peer]
# Name = laptop.example-vpn.dev
PublicKey = <public key for laptop.example-vpn.dev>
AllowedIPs = 192.0.2.4/32
```
 * peers: public-server1
 * full `wg0.conf` config file for node:
```ini
[Interface]
# Name = laptop.example-vpn.dev
Address = 192.0.2.4/32
PrivateKey = <private key for laptop.example-vpn.dev>
DNS = 1.1.1.1

[Peer]
# Name = public-server1.example-vpn.tld
Endpoint = public-server1.example-vpn.tld:51820
PublicKey = <public key for public-server1.example-vpn.tld>
# routes traffic to itself and entire subnet of peers as bounce server
AllowedIPs = 192.0.2.1/24
PersistentKeepalive = 25
```

### phone.example-vpn.dev
 * public endpoint: (none, behind NAT)
 * own vpn ip address: `192.0.2.5`
 * can accept traffic for ips: `192.0.2.5/32`
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
Address = 192.0.2.5/32
PrivateKey = <private key for phone.example-vpn.dev>
DNS = 1.1.1.1
```
 * config as peer:
```ini
[Peer]
# phone.example-vpn.dev
PublicKey = <public key for phone.example-vpn.dev>
AllowedIPs = 192.0.2.5/32
```
 * peers: public-server1
 * full `wg0.conf` config file for node:
```ini
[Interface]
# Name = phone.example-vpn.dev
Address = 192.0.2.5/32
PrivateKey = <private key for phone.example-vpn.dev>
DNS = 1.1.1.1

[Peer]
# Name = public-server1.example-vpn.tld
Endpoint = public-server1.example-vpn.tld:51820
PublicKey = <public key for public-server1.example-vpn.tld>
# routes traffic to itself and entire subnet of peers as bounce server
AllowedIPs = 192.0.2.1/24
PersistentKeepalive = 25
```


<center>
    
Suggest changes: https://github.com/pirate/wireguard-docs/issues
    
</center>
