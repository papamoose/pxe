#!/bin/bash

# Global Variables
preseed_server="http://10.13.37.205"
host="host/debian-host"
wd='/root'

main(){
  rootkey
  network
  debconf
}

# add rserver key, gives us access from rserver
rootkey(){
  mkdir $wd/.ssh
}

network(){
# set interface
# https://help.ubuntu.com/12.04/serverguide/network-configuration.html#name-resolution
/bin/cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
  dns-nameservers 10.13.37.206
EOF
/etc/init.d/networking restart
}

debconf(){
  # all answers go in this file
  /usr/bin/apt-get install debconf-utils -y
  wget $preseed_server/$host/files/debconf
  debconf-set-selections debconf
  rm debconf
}

# call main and GO!
main
