#!/bin/sh

# This script will be called with tun/tap device name as parameter 1, and local IP as parameter 4
# See https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html (--up cmd)
echo "Updating TRANSMISSION_BIND_ADDRESS_IPV4 to the ip of $1 : $4"
export TRANSMISSION_BIND_ADDRESS_IPV4=$4

#mkdir -p ${TRANSMISSION_HOME}
#dockerize -template /etc/transmission/settings.tmpl:${TRANSMISSION_HOME}/settings.json /bin/true

if [ ! -e "/dev/random" ]; then
  # Avoid "Fatal: no entropy gathering module detected" error
  echo "INFO: /dev/random not found - symlink to /dev/urandom"
  ln -s /dev/urandom /dev/random
fi

. /scripts/userSetup.sh

echo "STARTING SABNZBD"
#exec sudo -u ${RUN_AS} /usr/bin/transmission-daemon -g ${TRANSMISSION_HOME} --logfile ${TRANSMISSION_HOME}/transmission.log &
exec sudo -u ${RUN_AS} /etc/init.d/sabnzbdplus start &

echo "Startup script complete."
