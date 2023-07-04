# minimal server config
# You can specify all the server options like Port in ~/ssh.config in a "Host example.com" section.
server "server1"
  HostName="example.com"

# server that is disabled and overrides default options
server "server2"
  enabled=0 # disable the server and all its tunnels. Default is 1
  HostName="example.com"
  Port=2222
  User="root"
  IdentityFile="/root/.ssh/id_ed25519"
  StrictHostKeyChecking=yes # default is accept-new
  ServerAliveInterval="10" # default 30
  ConnectionAttempts="20"  # default 10

# remote tunnel
tunnelR "server1_http_to_local_8080"
  enabled=0 # disabled
  servername="server1"
  remoteaddress="*" # all interfaces and addresses
  remoteport=80
  localaddress="127.0.0.1"
  localport=8080

# local tunnel
tunnelL "local_smtp_to_server1_http"
  enabled=0 # disabled
  servername="server1"
  localaddress="127.0.0.1"
  localport=25
  remoteaddress="mail.example.com"  # specify the listen address
  remoteport=25

# dynamic tunnel
tunnelD "socks_proxy"
  enabled=0 # disabled
  servername="server1"
  localaddress="127.0.0.1"
  localport=1080

# TCP tunnel
tunnelW "vpn"
  enabled=0 # disabled
  servername="server1"
  Tunnel="point-to-point"
  localdev="any"
  remotedev="any"

