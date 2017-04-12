#!/bin/sh
set -e

# Display settings on standard out.

#USER_NAME="jdownloader"
echo "===================="
echo "JDownloader settings"
echo "===================="
echo
echo "  User:      ${USER_NAME}"
echo "  UID:        ${USER_UID}"
#echo "  UID:        ${JDOWNLOADER_UID}"
#echo "  GID:        ${JDOWNLOADER_GID}"
echo

# Change UID / GID of JDownloader user.
printf "Updating UID / GID... "
[[ $(id -u ${USER_NAME}) == ${USER_UID} ]] || usermod  -o -u ${USER_UID} ${USER_NAME}
[[ $(id -g ${USER_NAME}) == ${USER_UID} ]] || groupmod -o -g ${USER_UID} ${USER_NAME}
echo "[DONE]"

# Set directory permissions.
printf "Setting permissions... "
chown -R ${USER_NAME}: /jdownloader
chown ${USER_NAME}: /media
echo "[DONE]"

# Finally, start JDownloader.
echo "Starting JDownloader..."
exec su -pc "exec java -Djava.awt.headless=true -jar JDownloader.jar 2>&1 >/dev/null" $USER_NAME