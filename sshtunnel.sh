#!/bin/sh
last_section_type=""
num=0
servers=""
rm -f /tmp/sshtunnel-*

_clean_vars() {
  enabled="1"
  HostName=""
  User=""
  Port=""
  IdentityFile=""
  StrictHostKeyChecking="accept-new"
  ServerAliveInterval="30"
  ServerAliveCountMax="2"
  ConnectionAttempts="10"
  servername=""
  remoteaddress=""
  remoteport=""
  localaddress=""
  localport=""
  Tunnel=""
  localdev=""
  remotedev=""
}

_end_section() {
  [ -z "$section" ] && return 1
  num=$((num+=1))
  [ "$enabled" != "1" ] && >&2 echo "$last_section_type $section: disabled" && return 1
  >&2 echo "load $last_section_type $section"
  case $last_section_type in
    "S")
      [ -z "$HostName" ] && >&2 echo "server $section: no HostName" && return 1
      local args="$HostName ${Port:+-p $Port} ${User:+-l $User} ${IdentityFile:+-i $IdentityFile} -o StrictHostKeyChecking=${StrictHostKeyChecking} -o ServerAliveInterval=${ServerAliveInterval} -o ServerAliveCountMax=${ServerAliveCountMax} -o ConnectionAttempts=${ConnectionAttempts}"
      printf "%s" "$args" > "/tmp/sshtunnel-$section"
      servers="$servers $section"
      ;;
    "R")
      [ -z "$servername" ] && >&2 echo "tunnelR $section: no servername" && return 1
      [ -z "$remoteaddress" ] && >&2 echo "tunnelR $section: no remoteaddress" && return 1
      [ -z "$remoteport" ] && >&2 echo "tunnelR $section: no remoteport" && return 1
      [ -z "$localaddress" ] && >&2 echo "tunnelR $section: no localaddress" && return 1
      [ -z "$localport" ] && >&2 echo "tunnelR $section: no localport" && return 1
      local args=" -R $remoteaddress:$remoteport:$localaddress:$localport"
      printf "%s" "$args" > "/tmp/sshtunnel-$servername-R-$num"
      ;;
    "L")
      [ -z "$servername" ] && >&2 echo "tunnelL $section: no servername" && return 1
      [ -z "$remoteaddress" ] && >&2 echo "tunnelL $section: no remoteaddress" && return 1
      [ -z "$remoteport" ] && >&2 echo "tunnelL $section: no remoteport" && return 1
      [ -z "$localaddress" ] && >&2 echo "tunnelL $section: no localaddress" && return 1
      [ -z "$localport" ] && >&2 echo "tunnelL $section: no localport" && return 1
      local args=" -L $localaddress:$localport:$remoteaddress:$remoteport"
      printf "%s" "$args" > "/tmp/sshtunnel-$servername-L-$num"
      ;;
    "D")
      [ -z "$servername" ] && >&2 echo "tunnelD $section: no servername" && return 1
      [ -z "$localaddress" ] && >&2 echo "tunnelD $section: no localaddress" && return 1
      [ -z "$localport" ] && >&2 echo "tunnelD $section: no localport" && return 1
      local args=" -D $localaddress:$localport"
      printf "%s" "$args" > "/tmp/sshtunnel-$servername-D-$num"
      ;;
    "W")
      [ -z "$servername" ] && >&2 echo "tunnelW $section: no servername" && return 1
      Tunnel="${Tunnel:-point-to-point}"
      localdev="${localdev:-any}"
      remotedev="${remotedev:-any}"
      local args=" -o Tunnel=$Tunnel -w $localdev:$remotedev"
      printf "%s" "$args" > "/tmp/sshtunnel-$servername-W-$num"
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
  _clean_vars
  section="$1"
  [ -z "$section" ] && >&2 echo "server has no name" && last_section_type="" && return 1
  last_section_type="S"
}

tunnelR() {
  _end_section
  _clean_vars
  def_name="R$num"
  section="${1:-$def_name}"
  last_section_type="R"
}

tunnelL() {
  _end_section
  _clean_vars
  def_name="L$num"
  section="${1:-$def_name}"
  last_section_type="L"
}

tunnelD() {
  _end_section
  _clean_vars
  def_name="D$num"
  section="${1:-$def_name}"
  last_section_type="D"
}

tunnelW() {
  _end_section
  _clean_vars
  def_name="W$num"
  section="${1:-$def_name}"
  last_section_type="W"
}


_ssh_connect() {
  local server="$1"
  local ssh_cmd_args="$2"
  while :
  do
    echo >&2 "connect to $server: ssh $ssh_cmd_args"
    local t0=$(date +%s)
    ssh $ssh_cmd_args -N -o ExitOnForwardFailure=yes -o BatchMode=yes
    local exit_code="$?"
    # Reconnect immediately when the connection was lost, but wait for a minute if ssh was terminating just recently
    local t1=$(date +%s)
    local uptime="$((t1 - t0))"
    local delay=0
    [ "$uptime" -lt 60 ] && delay=60
    echo >&2 "$server: ssh exit code $exit_code after $uptime sec. Retry after $delay sec"
    sleep "$delay"
  done
}

_start_server_connections() {
  [ -r /root/.ssh/sshtunnel.config.sh ] || return 1
  >&2 echo "load from /root/.ssh/sshtunnel.config.sh"
  _clean_vars
  . /root/.ssh/sshtunnel.config.sh
  _end_section
  [ "$num" = "0" ] && >&2 echo "no ssh tunnels configured" && return 1
  for server in $servers
  do
    local args="$(cat /tmp/sshtunnel-$server-*)"
    if [ -n "$args" ]; then
      args="$(cat /tmp/sshtunnel-$server) $args"
      _ssh_connect "$server" "$args" &
    else
      >&2 echo "server $server: no tunnels"
    fi
  done
}

_start_hosts_connections() {
  [ -r /root/.ssh/config ] || return 1
  >&2 echo "load from /root/.ssh/config"
  ssh_conf_hosts=$(grep Host.*_tun$ /root/.ssh/config | cut -d' ' -f2)
  for server in $ssh_conf_hosts
  do
    _ssh_connect "$server" "$server" &
  done
}

_start_hosts_connections
_start_server_connections

wait
