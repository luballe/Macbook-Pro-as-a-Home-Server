# 6. Remote access with WireGuard

To reach the server from outside home without exposing SSH to the internet: a small
WireGuard network between the server and your laptop.

## Server

```bash
sudo apt install wireguard
umask 077
wg genkey | sudo tee /etc/wireguard/wg-home.key | wg pubkey   # server public key
sudo cp config/wireguard-home.conf.example /etc/wireguard/wg-home.conf   # edit it
sudo systemctl enable wg-quick@wg-home
sudo systemctl start wg-quick@wg-home    # enable --now did not always start it
```

[config/wireguard-home.conf.example](../config/wireguard-home.conf.example) keeps
the private key in its own root-only file and loads it with `PostUp`, so the
`.conf` can be shared or backed up without the key.

On the router, forward **UDP 51830** to the server's LAN IP. Test the forward from
outside (for example from a phone hotspot) with `tcpdump -ni any udp port 51830`
on the server: if no packets arrive, the router is dropping them.

## Laptop (macOS example)

```ini
[Interface]
PrivateKey = <laptop-private-key>
Address = 10.60.0.2/32
MTU = 1380

[Peer]
PublicKey = <server-public-key>
Endpoint = <your-home-public-ip-or-dyndns>:51830
AllowedIPs = 10.60.0.1/32
PersistentKeepalive = 25
```

Keep this file out of synced folders (iCloud, Dropbox): it contains a private key.
The macOS WireGuard app runs one tunnel at a time.

## One SSH name, at home or away

In `~/.ssh/config`, use the LAN address when it answers and the tunnel otherwise:

```text
Match originalhost home-server !exec "nc -z -G 2 192.168.1.10 22 >/dev/null 2>&1"
    HostName 10.60.0.1
    HostKeyAlias home-server
Host home-server
    HostName 192.168.1.10
    User youruser
```

`originalhost` is the name you typed, so list every alias you use in the `Match`.
Other machines reachable from the server can then be used with
`ProxyJump home-server`, without opening their SSH ports to the internet.
