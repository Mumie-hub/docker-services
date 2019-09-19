#!/bin/sh
set -e

#ENV
OS=""

#Functions
DectectOS(){
  if [ -e /etc/alpine-release ]; then
    OS="alpine"
  elif [ -e /etc/os-release ]; then
    if /bin/grep -q "NAME=\"Ubuntu\"" /etc/os-release ; then 
      OS="ubuntu"
    fi
  fi
}

AutoUpgrade(){
    if [ "${OS}" == "alpine" ]; then
        /sbin/apk --no-cache upgrade
        /bin/rm -rf /var/cache/apk/*
    elif [ "${OS}" == "ubuntu" ]; then
        export DEBIAN_FRONTEND=noninteractive
        /usr/bin/apt-get update
        /usr/bin/apt-get -y --no-install-recommends dist-upgrade
        /usr/bin/apt-get -y autoclean
        /usr/bin/apt-get -y clean 
        /usr/bin/apt-get -y autoremove
        /bin/rm -rf /var/lib/apt/lists/*
    fi
}

AddCredentials(){
    if [ ! -f $JDPATH/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json ]; then
      cat << EOF > $JDPATH/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
{
  "autoconnectenabledv2" : true,
  "email" : "${DOCKJDMAIL}",
  "password" : "${DOCKJDPASSWD}"
}
EOF
      /bin/chown -R "${MYUSER}":"${MYUSER}" $JDPATH/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
      /bin/chmod 0664 $JDPATH/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
    fi
}

SetDownloadFolder(){
  if [ -f $JDPATH/cfg/org.jdownloader.settings.GeneralSettings.json ]; then
    sed -i "s|\s*\"defaultdownloadfolder\"\s*:\s*\"\"|\ \ \ \ \ \ \ \ \"defaultdownloadfolder\":\ \"/downloads\"|g" $JDPATH/cfg/org.jdownloader.settings.GeneralSettings.json
  fi
}

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
#[[ $(id -u ${USER_NAME}) == ${USER_UID} ]] || usermod  -o -u ${USER_UID} ${USER_NAME}
#[[ $(id -g ${USER_NAME}) == ${USER_UID} ]] || groupmod -o -g ${USER_UID} ${USER_NAME}
echo "[DONE]"

# Set directory permissions.
printf "Setting permissions... "
chown -R ${USER_NAME}: /jdownloader
chown ${USER_NAME}: /media
echo "[DONE]"

#run functions##############################
DectectOS
AutoUpgrade
#AddCredentials
#SetDownloadFolder

# Finally, start JDownloader.
echo "Starting JDownloader..."
exec su -pc "exec java -Djava.awt.headless=true -jar ${JDPATH}/JDownloader.jar 2>&1 >/dev/null" $USER_NAME