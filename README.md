# sshtunnel SSH tunnelling SystemD daemon.

This is a port of [OpenWrt sshtunnel](https://openwrt.org/docs/guide-user/services/ssh/sshtunnel).
So basic documentation is same but implementation differ.

## Usage
Create `/etc/sshtunnel.config.sh` file and configure server and a tunnel:
```
server "srv_us"
  HostName="srv.us"
  User="root"
  IdentityFile="/root/.ssh/id_ed25519"

tunnelR "srv_us_http"
  servername="srv_us"
  remoteaddress="1"
  remoteport=80
  localaddress="127.0.0.1"
  localport=8080
```

Then restart with `systemctl restart sshtunnel`.

Then you'll have ssh started you can check with `ps ax | grep ssh`:

    ssh root@srv.us -i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new -R 1:80:127.0.0.1:8080 -N -o ExitOnForwardFailure=yes -o BatchMode=yes

To read logs use:

    sudo journalctl -f -n 50 -u sshtunnel

See [sshtunnel.config.sh](./sshtunnel.config.sh) for more samples.
The file is a DSL over a plain shell script.

### Supported options

* `server` specify SSH server options. One server may have multiple tunnels.
  * `HostName` IP or domain. Required
  * `User` default `root`
  * `Port` 
  * `IdentityFile` you better to specify. If empty then will try `/root/.ssh/id_rsa`, then `/root/.ssh/id_ed25519`
  * `StrictHostKeyChecking` default `accept-new`, or if you are afraid that server change it in future then set to `no`
* `tunnelR` remote to local tunnel
  * `remoteaddress`, `remoteport`, `localaddress`, `localport`
* `tunnelL` local to remote tunnel
  * `remoteaddress`, `remoteport`, `localaddress`, `localport`
* `tunnelD` dynamic tunnel e.g. SOCKS proxy
  * `localaddress`, `localport`
* `tunnelW` VPN
  * `Tunnel` `point-to-point` (default) or `ethernet`. See `Tunnel` in man ssh_config
  * `localdev`, `remotedev` tun devices. See `TunnelDevice` in man ssh_config

Options from SSH config file are starting from Upper case but the sshtunnel specific options starts with lowercase.

## Installation

    sudo cp sshtunnel.sh /usr/bin/sshtunnel
    sudo chmod +x /usr/bin/sshtunnel
    sudo cp sshtunnel.service /etc/systemd/system/
    sudo systemctl daemon-reload

## See also
* [SystemD SSH client unit](https://gist.github.com/guettli/31242c61f00e365bbf5ed08d09cdc006#file-ssh-tunnel-service) based on SystemD templates. Configure port forwardings in the SSH config
