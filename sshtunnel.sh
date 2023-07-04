#!/bin/sh
last_section_type=""
num=0
servers=""
rm -f /tmp/sshtunnel-*

_end_section() {
  num=$((num+=1))
  case $last_section_type in
    "S")
      [ -z "$IdentityFile" ] && >&2 echo "server $section: no IdentityFile" && return 1
      [ -z "$Host" ] && >&2 echo "server $section: no Host" && return 1
      [ -z "$Port" ] && >&2 echo "server $section: no Port" && return 1
      [ -z "$User" ] && >&2 echo "server $section: no User" && return 1
#      -o TCPKeepAlive=yes -o LogLevel=DEBUG
      printf "%s" " -o StrictHostKeyChecking=accept-new -i $IdentityFile $User@$Host -p $Port" > "/tmp/sshtunnel-$section-0"
      servers="$servers $section"
      ;;
    "R")
      [ -z "$Server" ] && >&2 echo "tunnelR $section: no Server" && return 1
      [ -z "$RemoteAddress" ] && >&2 echo "tunnelR $section: no RemoteAddress" && return 1
      [ -z "$RemotePort" ] && >&2 echo "tunnelR $section: no RemotePort" && return 1
      [ -z "$LocalAddress" ] && >&2 echo "tunnelR $section: no LocalAddress" && return 1
      [ -z "$LocalPort" ] && >&2 echo "tunnelR $section: no LocalPort" && return 1
      printf "%s" " -R $RemoteAddress:$RemotePort:$LocalAddress:$LocalPort" > "/tmp/sshtunnel-$Server-R-$num"
      ;;
    "L")
      [ -z "$Server" ] && >&2 echo "tunnelL $section: no Server" && return 1
      [ -z "$RemoteAddress" ] && >&2 echo "tunnelL $section: no RemoteAddress" && return 1
      [ -z "$RemotePort" ] && >&2 echo "tunnelL $section: no RemotePort" && return 1
      [ -z "$LocalAddress" ] && >&2 echo "tunnelL $section: no LocalAddress" && return 1
      [ -z "$LocalPort" ] && >&2 echo "tunnelL $section: no LocalPort" && return 1
      printf "%s" " -L $LocalAddress:$LocalPort:$RemoteAddress:$RemotePort" > "/tmp/sshtunnel-$Server-L-$num"
      ;;
    "D")
      [ -z "$Server" ] && >&2 echo "tunnelD $section: no Server" && return 1
      [ -z "$LocalAddress" ] && >&2 echo "tunnelD $section: no LocalAddress" && return 1
      [ -z "$LocalPort" ] && >&2 echo "tunnelD $section: no LocalPort" && return 1
      printf "%s" " -D $LocalAddress:$LocalPort" > "/tmp/sshtunnel-$Server-D-$num"
      ;;
    "W")
      [ -z "$Server" ] && >&2 echo "tunnelW $section: no Server" && return 1
      [ -z "$vpntype" ] && >&2 echo "tunnelW $section: no vpntype" && return 1
      [ -z "$localdev" ] && >&2 echo "tunnelW $section: no localdev" && return 1
      [ -z "$remotedev" ] && >&2 echo "tunnelW $section: no remotedev" && return 1
      printf "%s" " -o Tunnel=$vpntype -w $localdev:$remotedev" > "/tmp/sshtunnel-$Server-W-$num"
      ;;
    "")
      ;;
    *)
      >&2 echo "unknown $last_section_type"
      ;;
  esac
  return 0
}

server() {
  _end_section
  section="$1"
  [ -z "$section" ] && >&2 echo "server has no name" && last_section_type="" && return 1
  last_section_type="S"
}

tunnelR() {
  _end_section
  def_name="R$num"
  section="${1:-$def_name}"
  last_section_type="R"
}

tunnelL() {
  _end_section
  def_name="R$num"
  section="${1:-$def_name}"
  last_section_type="R"
}

tunnelD() {
  _end_section
  def_name="D$num"
  section="${1:-$def_name}"
  last_section_type="D"
}

tunnelW() {
  _end_section
  def_name="W$num"
  section="${1:-$def_name}"
  last_section_type="W"
}

. /etc/sshtunnel.config.sh

_end_section

_ssh_connect() {
  while :
  do
    echo >&2 "connect to $ARGS"
    ssh $ARGS
    echo >&2 "ssh failed with code $?. Retry with -N"
    ssh $ARGS -N
    sleep 10
  done
}

for serv in $servers
do
  ARGS="$(cat /tmp/sshtunnel-$serv-*) -o ExitOnForwardFailure=yes -o BatchMode=yes -T"
  _ssh_connect $ARGS &
done

wait
