# SABnzbd and OpenVPN

FROM ubuntu
MAINTAINER Mumie

ENV ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8' \
    USER_NAME="abc" \
    PUID=\
    PGID=\
    OPENVPN_USERNAME=**None**  \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    SABNZBD_CONFIG_DIR=/config \
    DOWNLOAD_DIR=/tmp/media/downloads \
    INCOMPLETE_DIR=/tmp/media/incomplete \
    WATCH_DIR=

# Update packages and install software
RUN apt-get update \
    && apt-get -y install software-properties-common \
#    && add-apt-repository multiverse \
    && add-apt-repository ppa:jcfp/sab-addons \
    && apt-get update \
    && apt-get install -y openvpn curl sudo rar unrar zip unzip wget sabnzbdplus par2-tbb par2-mt python-sabyenc \
    && curl -sLO https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb \
    && dpkg -i dumb-init_*.deb \
    && rm -rf dumb-init_*.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d $SABNZBD_CONFIG_DIR -s /bin/false $USER_NAME \
    && usermod -G users $USER_NAME \
    # needs to be fixed no service for sabnzbd
    && printf "USER=root\nHOST=0.0.0.0\nPORT=8080\nCONFIG=/config\n" > /etc/default/sabnzbdplus \
    && /etc/init.d/sabnzbdplus start

ADD openvpn/ /etc/openvpn/
ADD scripts/ /scripts/
RUN chmod +x /etc/openvpn/start.sh \
    && chmod +x /scripts/*.sh


VOLUME $DOWNLOAD_DIR
VOLUME /config

EXPOSE 8080 8090

CMD ["dumb-init", "/etc/openvpn/start.sh"]
