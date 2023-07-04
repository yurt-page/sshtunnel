# sshtunnel
SSH tunnelling systemd daemon.

This is Port of [OpenWrt sshtunnel](https://openwrt.org/docs/guide-user/services/ssh/sshtunnel) so basic documentation is same.

## Installation

    sudo cp sshtunnel.sh /usr/bin/sshtunnel
    sudo chmod +x /usr/bin/sshtunnel
    sudo systemctl daemon-reload


## Usage
Create `/etc/sshtunnel.config.sh` file and configure server and a tunnel:
```
server "srv_us"
  Host="srv.us"
  Port=22
  User="root"
  IdentityFile="/root/.ssh/id_ed25519"

tunnelR "http"
  Server="srv_us"
  RemoteAddress="1"
  RemotePort=80
  LocalAddress="127.0.0.1"
  LocalPort=8080
```

Then restart with `systemctl restart sshtunnel`.

Then you'll have ssh started you can check with `ps ax | grep ssh`:

    ssh -R 1:80:127.0.0.1:8080 -o StrictHostKeyChecking=accept-new -i /root/.ssh/id_ed25519 root@srv.us -p 22

To read logs use:

    sudo journalctl -f -n 50 -u sshtunnel

See [sshtunnel.config.sh](./sshtunnel.config.sh) for more samples.
