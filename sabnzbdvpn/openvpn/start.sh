#!/bin/sh

# add OpenVPN user/pass
if [ "${OPENVPN_USERNAME}" = "**None**" ] || [ "${OPENVPN_PASSWORD}" = "**None**" ] ; then
 echo "OpenVPN credentials not set. Is this right?. In case of using Custom Config"
else
  echo "Setting OPENVPN credentials..."
  mkdir -p /config
  echo $OPENVPN_USERNAME > /config/openvpn-credentials.txt
  echo $OPENVPN_PASSWORD >> /config/openvpn-credentials.txt
  chmod 600 /config/openvpn-credentials.txt
fi

#dockerize -template /etc/transmission/environment-variables.tmpl:/etc/transmission/environment-variables.sh /bin/true

if [ -n "${LOCAL_NETWORK-}" ]; then
  eval $(/sbin/ip r l m 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}')
  if [ -n "${GW-}" -a -n "${INT-}" ]; then
    echo "adding route to local network $LOCAL_NETWORK via $GW dev $INT"
    /sbin/ip r a "$LOCAL_NETWORK" via "$GW" dev "$INT"
  fi
fi

. /scripts/userSetup.sh

CONTROL_OPTS="--script-security 2 --up /scripts/start.sh --down /scripts/stop.sh"

exec openvpn $CONTROL_OPTS $OPENVPN_OPTS --config "$OPENVPN_CONFIG"
