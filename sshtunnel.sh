#!/bin/sh
last_section_type=""
num=0
servers=""
rm -f /tmp/sshtunnel-*

_end_section() {
  num=$((num+=1))
  case $last_section_type in
    "S")
      [ -z "$Host" ] && >&2 echo "server $section: no Host" && return 1
      local ARGS="$Host"
      [ -n "$User" ] && ARGS="$User@$ARGS"
      [ -n "$Port" ] && ARGS="$ARGS -p $Port "
      [ -n "$IdentityFile" ] && ARGS="$ARGS -i $IdentityFile"
      StrictHostKeyChecking="${StrictHostKeyChecking:-accept-new}"
      ARGS="$ARGS -o StrictHostKeyChecking=$StrictHostKeyChecking"
      printf "%s" "$ARGS" > "/tmp/sshtunnel-$section"
      servers="$servers $section"
      ;;
    "R")
      [ -z "$servername" ] && >&2 echo "tunnelR $section: no servername" && return 1
      [ -z "$remoteaddress" ] && >&2 echo "tunnelR $section: no remoteaddress" && return 1
      [ -z "$remoteport" ] && >&2 echo "tunnelR $section: no remoteport" && return 1
      [ -z "$localaddress" ] && >&2 echo "tunnelR $section: no localaddress" && return 1
      [ -z "$localport" ] && >&2 echo "tunnelR $section: no localport" && return 1
      printf "%s" " -R $remoteaddress:$remoteport:$localaddress:$localport" > "/tmp/sshtunnel-$servername-R-$num"
      ;;
    "L")
      [ -z "$servername" ] && >&2 echo "tunnelL $section: no servername" && return 1
      [ -z "$remoteaddress" ] && >&2 echo "tunnelL $section: no remoteaddress" && return 1
      [ -z "$remoteport" ] && >&2 echo "tunnelL $section: no remoteport" && return 1
      [ -z "$localaddress" ] && >&2 echo "tunnelL $section: no localaddress" && return 1
      [ -z "$localport" ] && >&2 echo "tunnelL $section: no localport" && return 1
      printf "%s" " -L $localaddress:$localport:$remoteaddress:$remoteport" > "/tmp/sshtunnel-$servername-L-$num"
      ;;
    "D")
      [ -z "$servername" ] && >&2 echo "tunnelD $section: no servername" && return 1
      [ -z "$localaddress" ] && >&2 echo "tunnelD $section: no localaddress" && return 1
      [ -z "$localport" ] && >&2 echo "tunnelD $section: no localport" && return 1
      printf "%s" " -D $localaddress:$localport" > "/tmp/sshtunnel-$servername-D-$num"
      ;;
    "W")
      [ -z "$servername" ] && >&2 echo "tunnelW $section: no servername" && return 1
      [ -z "$Tunnel" ] && >&2 echo "tunnelW $section: no Tunnel" && return 1
      [ -z "$localdev" ] && >&2 echo "tunnelW $section: no localdev" && return 1
      [ -z "$remotedev" ] && >&2 echo "tunnelW $section: no remotedev" && return 1
      printf "%s" " -o Tunnel=$Tunnel -w $localdev:$remotedev" > "/tmp/sshtunnel-$servername-W-$num"
      ;;
    "")
      ;;
    *)
      >&2 echo "unknown $last_section_type"
      ;;
  esac
  Host=""
  User=""
  Port=""
  IdentityFile=""
  StrictHostKeyChecking=""
  servername=""
  remoteaddress=""
  remoteport=""
  localaddress=""
  localport=""
  Tunnel=""
  localdev=""
  remotedev=""
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
    echo >&2 "ssh exit code $?. Retry"
    sleep 5
  done
}

for serv in $servers
do
  ARGS="$(cat /tmp/sshtunnel-$serv-*)"
  if [ -n "$ARGS" ]; then
    ARGS="$(cat /tmp/sshtunnel-$serv) $ARGS -N -o ExitOnForwardFailure=yes -o BatchMode=yes -o ServerAliveInterval=60 -o ConnectionAttempts=5"
    _ssh_connect $ARGS &
  else
    >&2 echo "server $serv: no tunnels"
  fi
done

wait
