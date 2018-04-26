#!/bin/sh

. /etc/profile

# More/less taken from https://github.com/linuxserver/docker-baseimage-alpine/blob/3eb7146a55b7bff547905e0d3f71a26036448ae6/root/etc/cont-init.d/10-adduser

USER_HOME=/home/${USER_NAME}

mkdir ${USER_HOME} \
    ${SABNZBD_CONFIG_DIR} \
    ${DOWNLOAD_DIR} \
    ${INCOMPLETE_DIR} \
    ${WATCH_DIR}

if [ -n "$PUID" ]; then
    if [ ! "$(id -u ${USER_NAME})" -eq "$PUID" ]; then usermod -o -u "$PUID" ${USER_NAME} ; fi
    if [ ! "$(id -g ${USER_NAME})" -eq "$PGID" ]; then groupmod -o -g "$PGID" ${USER_NAME} ; fi
fi

echo "Setting owner for Folder paths to ${PUID}:${PGID}"

chown -R ${USER_NAME}:${USER_NAME} \
    ${USER_HOME} \
    ${SABNZBD_CONFIG_DIR} \
    ${DOWNLOAD_DIR} \
    ${INCOMPLETE_DIR} \
    ${WATCH_DIR}

echo "
-------------------------------------
Sabnzbd will run as
-------------------------------------
User name:   ${USER_NAME}
User uid:    $(id -u ${USER_NAME})
User gid:    $(id -g ${USER_NAME})
-------------------------------------
"