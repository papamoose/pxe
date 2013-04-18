#!/bin/bash

# Global Variables
preseed_server="http://10.13.37.205"
host="host/dns"
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
iface eth0 inet static
  address 10.13.37.215
  netmask 255.255.255.0
  gateway 10.13.37.1
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

owncloud(){
  echo 'deb http://download.opensuse.org/repositories/isv:ownCloud:community/Debian_6.0/ /' >> /etc/apt/sources.list.d/owncloud.list
  wget http://download.opensuse.org/repositories/isv:ownCloud:community/Debian_6.0/Release.key
  apt-key add - < Release.key
  rm Release.key

  apt-get update
  apt-get install -y owncloud

cat > /etc/apache2/sites-enabled/10-owncloud-redirect <<EOF
<VirtualHost *:80>
   ServerName owncloud.pk.lan
   ServerAlias ownlcoud.pklan.org owncloud
   DocumentRoot /var/www/owncloud
   Redirect permanent /secure https://owncloud.pk.lan
</VirtualHost>
EOF

cat > /etc/apache2/sites-enabled/10-owncloud-ssl <<EOF
<IfModule mod_ssl.c>
<VirtualHost *:443>
  ServerName owncloud.pk.lan
  ServerAlias owncloud.pklan.org owncloud
  ServerAdmin root@pklan.org
  DocumentRoot /var/www/owncloud
  SSLEngine on
  RackBaseURI /
  SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
  SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
  SSLVerifyClient         optional
  SSLOptions              +StdEnvVars
  SSLVerifyDepth          3
</VirtualHost>
</IfModule>
EOF

/etc/init.d/networking restart

cp -r /var/www/owncloud/data /var/www/owncloud/data.bak


}


# call main and GO!
main
