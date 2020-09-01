#!/bin/bash

#. /etc/profile

# add OpenVPN user/pass deprecated
#if [ "${OPENVPN_USERNAME}" = "" ] || [ "${OPENVPN_PASSWORD}" = "" ] ; then
# echo "OpenVPN credentials not set. No credentials.txt will be created"
#else
#  echo "Setting OPENVPN credentials.txt ..."
#  echo $OPENVPN_USERNAME > /etc/openvpn/custom/openvpn-credentials.txt
#  echo $OPENVPN_PASSWORD >> /etc/openvpn/custom/openvpn-credentials.txt
#  chmod 600 /etc/openvpn/custom/openvpn-credentials.txt
#fi

#set routing gateway for the container
IFS=',' read -ra NETWORKS <<< "$LOCAL_NETWORKS"

if [ -n "${LOCAL_NETWORKS-}" ]; then
    eval $(/sbin/ip r s 0.0.0.0/0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}')

    for LOCAL_NETWORK in "${NETWORKS[@]}"; do
        if [ -n "${GW-}" -a -n "${INT-}" ]; then
            echo "adding route to local network $LOCAL_NETWORK via $GW dev $INT"
            /sbin/ip r a "$LOCAL_NETWORK" via "$GW" dev "$INT"
        fi
    done
fi

. /scripts/userSetup.sh

CONTROL_OPTS="--script-security 3 --route-up /scripts/start.sh --route-pre-down /scripts/stop.sh"
OPENVPN_CONFIG_PATH="$OPENVPN_CONFIG_DIR/$OPENVPN_CONFIG"

#printf "USER=${USER_NAME}\nHOST=0.0.0.0\nPORT=8080\nCONFIG=${SABNZBD_CONFIG_DIR}\n" > /etc/default/sabnzbdplus \
#/etc/init.d/sabnzbdplus start

exec openvpn $CONTROL_OPTS $OPENVPN_OPTS --config "$OPENVPN_CONFIG_PATH"
