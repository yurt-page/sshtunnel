# sshtunnel SSH tunnelling SystemD daemon.

Configure SSH tunnels and port forwardings.

> [!TIP]
> On a desktop linux you better to try [NetworkManager SSH plugin](https://github.com/danfruehauf/NetworkManager-ssh) 
> It allows to configure an SSH VPN with GUI.

If your computer is behind a NAT you can expose your website with a tunnel.
There are [a few of services that provides free or cheap tunnels](https://github.com/yurt-page/awesome-tunneling?tab=readme-ov-file#ssh-services)
e.g. https://localhost.run, https://srv.us etc. 


## Usage

### Set keys
To configure server and a tunnel you need to set up the SSH key for the server.
The sshtunnel is run by a `root` user. So you need to configure keys in its `/root/.ssh/` folder.
Let's ensure that it's exists with `sudo mkdir /root/.ssh/`.
You can generate a new key with a command `sudo ssh-keygen`.
Or you can copy your existing keys `sudo cp ~/.ssh/id_* /root/.ssh/`.

Also add a host key to `/root/.ssh/known_hosts` or use `StrictHostKeyChecking accept-new` bellow.

### Configure ~/.ssh/config
When the `sshtunnel` starts it reads `~/.ssh/config` finds all hosts that ends with `_tun` e.g. `Host router_tun` and starts an ssh connection to the host.
So edit the `sudo -e /root/.ssh/config` by this example:

```sh
Host router_tun
    HostName 192.168.1.1
    Port 2222
    User root
    ServerAliveInterval 30
    ConnectionAttempts 10
    StrictHostKeyChecking accept-new
    # When someone connect to the router's public IP on 80 port forward it to the local 8080 port
    RemoteForward 80 127.0.0.1:8080
    # When sendmail connecting to the local 25 port then connect to the router and forward to its 25 port  
    LocalForward 25 127.0.0.1:25
    # Start a SOCKS proxy on local 1080 port. Configure a browser to use it.
    DynamicForward 1080
```

The sshtunnel will also add `-N -o ExitOnForwardFailure=yes -o BatchMode=yes` options when starting the ssh connection.

Then restart with `systemctl restart sshtunnel` and check status with `systemctl status sshtunnel`.

If no any tunnel specified the sshtunnel stops and a service won't be running unless you restart it.


### Configure ~/.ssh/sshtunnel.config.sh

Another configuration file is `/root/.ssh/sshtunnel.config.sh`.
The file is a DSL over a plain shell script. It may be more expressive but has fewer options.

Edit the config file with `sudo -e /root/.ssh/sshtunnel.config.sh` e.g.:

```sh
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

See [sshtunnel.config.sh](./sshtunnel.config.sh) for more samples.


#### Supported options by sshtunnel.config.sh

* `server` specify SSH server options. One server may have multiple tunnels.
  * `enabled` set to `0` to disable.
  * `HostName` IP, domain or Host configured in `~/.ssh/config`. Required.
  * `User` default is a user that started the sshtunnel service i.e. `root`. You better to create a separate limited user on the server.
  * `Port` default `22`.
  * `IdentityFile` an absolute path to a private key. If empty then the ssh will try `/root/.ssh/id_rsa`, then `/root/.ssh/id_ed25519` etc. Set it only if name is non-standard.
  * `StrictHostKeyChecking` default `accept-new`. If you are afraid that server can change it in future then set to `no` to your own risk.
  * `ServerAliveInterval` default `30`.
  * `ServerAliveCountMax` default `2`.
  * `ConnectionAttempts` default `10`.
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
So use `man ssh_config` to see the meaning of options.
If you need more options e.g. `ProxyJump` then specify them in `~/.ssh/config`.

## Troubleshooting

Check that ssh has been started with `ps ax | grep ssh` e.g.:

    ssh root@srv.us -i /root/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new -R 1:80:127.0.0.1:8080 -N -o ExitOnForwardFailure=yes -o BatchMode=yes

To read logs use:

    sudo journalctl -u sshtunnel -f -n 50


## Installation

### Debian/Ubuntu

For Ubuntu use [PPA repository](https://code.launchpad.net/~stokito/+archive/ubuntu/utils):

    sudo add-apt-repository ppa:stokito/utils
    sudo apt update
    sudo apt install sshtunnel

Or install by downloading the package:

    wget -O /tmp/sshtunnel https://github.com/yurt-page/sshtunnel/releases/download/v1.0.2/sshtunnel_1.0.0_all.deb
    sudo dpkg -i /tmp/sshtunnel
    rm -f /tmp/sshtunnel

### From sources

    git clone git@github.com:yurt-page/sshtunnel.git
    cd sshtunnel
    # install files, service and reload systemd services    
    sudo make install_all
    # reload to test after changes
    sudo make restart
    sudo make stop

### Manual

    sudo cp sshtunnel.sh /usr/bin/sshtunnel
    sudo chmod +x /usr/bin/sshtunnel
    sudo cp sshtunnel.service /etc/systemd/system/
    sudo systemctl daemon-reload

## See also
* [SystemD SSH client unit](https://gist.github.com/guettli/31242c61f00e365bbf5ed08d09cdc006#file-ssh-tunnel-service) based on SystemD templates. Configure port forwardings in the SSH config
* [OpenWrt sshtunnel](https://openwrt.org/docs/guide-user/services/ssh/sshtunnel) for a router. This project is a port of the sshtunnel.
* [NetworkManager SSH plugin](https://github.com/danfruehauf/NetworkManager-ssh) 

