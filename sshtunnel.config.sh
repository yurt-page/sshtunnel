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
  Server="example1"
  RemoteAddress="domain1"
  RemotePort=80
  LocalAddress="127.0.0.1"
  LocalPort=8080

tunnelL
  Server="example1"
  LocalAddress="127.0.0.2"
  LocalPort=8080
  RemoteAddress="domain2"
  RemotePort=80

tunnelD
  Server="example2"
  LocalAddress="127.0.0.3"
  LocalPort=8080

tunnelW
  Server="example2"
  vpntype="point-to-point"
  localdev="any"
  remotedev="any"
