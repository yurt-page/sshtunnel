server "example1"
  Host="example.com"
  Port=1
  User="root"
  IdentityFile="/root/.ssh/id_ed25519"

server "example2"
  Host="example.com"
  Port=2
  User="root"
  IdentityFile="/root/.ssh/id_rsa"
  StrictHostKeyChecking=yes

tunnelR "http1"
  servername="example1"
  remoteaddress="domain1"
  remoteport=80
  localaddress="127.0.0.1"
  localport=8080

tunnelL
  servername="example1"
  localaddress="127.0.0.2"
  localport=8080
  remoteaddress="domain2"
  remoteport=80

tunnelD
  servername="example2"
  localaddress="127.0.0.3"
  localport=8080

tunnelW
  servername="example2"
  Tunnel="point-to-point"
  localdev="any"
  remotedev="any"
