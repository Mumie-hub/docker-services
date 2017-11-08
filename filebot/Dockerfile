FROM ubuntu

MAINTAINER Mumie

ENV USER_NAME="filebot" \
    USER_ID=1002 \
    GROUP_ID=1002 \
    UMASK=0002 \
    DEBIAN_FRONTEND=noninteractive \
    CONFIG_DIR="/config" \
    CONFIG_FILE="filebot.conf" \
    MOUNT_POINT="/mnt" \
    WATCH_DIR="/mnt/input" \
    OUTPUT_DIR="/mnt/output"
#    IGNORE_EVENTS=0

# Use of inotify, python3
RUN set -x \
    && apt-get -q update \
    && apt-get install -qy inotify-tools openjdk-8-jre-headless wget python3 \
    && groupadd -g ${USER_ID} ${USER_NAME} \
    && useradd -u ${USER_ID} -g ${GROUP_ID} -d /home/${USER_NAME} -m -s /bin/sh ${USER_NAME} \
    && mkdir -p /files /config \
    && chown -R ${USER_NAME}:${USER_NAME} /files \
    && wget -qO /files/filebot.deb 'https://app.filebot.net/download.php?type=deb&arch=amd64&version=4.7.7' \
    && dpkg -i /files/filebot.deb && rm /files/filebot.deb \
    && apt-get -y purge wget \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* /var/cache/apt/*

# Add scripts. Make sure start.sh, and filebot.sh are executable by $USER_ID
ADD start.sh /start.sh
ADD filebot.sh /files/filebot.sh
ADD filebot.conf /files/filebot.conf
ADD monitor.sh /files/monitor.sh
ADD checkconfig.sh /files/checkconfig.sh
ADD setuser.py /setuser.py

RUN \
    chmod a+x /start.sh \
    && chmod a+wx /files/filebot.sh \
    && chmod a+w /files/filebot.conf \
    && chmod +x /files/monitor.sh \
    && chmod +x /files/checkconfig.sh \
    && chmod +x /setuser.py \
    && chown -R ${USER_NAME}:${USER_NAME} /files \
    && chown -R ${USER_NAME}:${USER_NAME} $CONFIG_DIR

#VOLUME [${WATCH_DIR}, ${OUTPUT_DIR}, ${CONFIG_DIR}]

ENTRYPOINT ["/start.sh"]

# -v /etc/localtime:/etc/localtime:ro
# -v /home/mumie/.config/filebot:/config:rw
# -v /mnt/downloads:/input:rw 
# -v /mnt/uploads:/output:rw