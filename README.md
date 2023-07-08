# sshtunnel SSH tunnelling SystemD daemon.

This is a port of [OpenWrt sshtunnel](https://openwrt.org/docs/guide-user/services/ssh/sshtunnel).
So basic documentation is same but implementation differ.

* `tunnelR` remote to local tunnel
* `tunnelL` local to remote tunnel
* `tunnelD` dynamic tunnel e.g. SOCKS proxy
* `tunnelW` VPN

## Installation

    sudo cp sshtunnel.sh /usr/bin/sshtunnel
    sudo chmod +x /usr/bin/sshtunnel
    sudo cp sshtunnel.service /etc/systemd/system/
    sudo systemctl daemon-reload


## Usage
Create `/etc/sshtunnel.config.sh` file and configure server and a tunnel:
```
server "srv_us"
  Host="srv.us"
  User="root"
  IdentityFile="/root/.ssh/id_ed25519"

tunnelR "http"
  Server="srv_us"
  RemoteAddress="1"
  RemotePort=80
  LocalAddress="127.0.0.1"
  LocalPort=8080
```

The file is a plain shell script with DSL.
Options from SSH config file are starting from Upper case but the sshtunnel specific options starts with lowercase.

Then restart with `systemctl restart sshtunnel`.

Then you'll have ssh started you can check with `ps ax | grep ssh`:

    ssh root@srv.us -i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new -R 1:80:127.0.0.1:8080 -N -o ExitOnForwardFailure=yes -o BatchMode=yes

To read logs use:

    sudo journalctl -f -n 50 -u sshtunnel

See [sshtunnel.config.sh](./sshtunnel.config.sh) for more samples.
