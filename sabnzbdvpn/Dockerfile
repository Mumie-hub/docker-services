# SABnzbd and OpenVPN

FROM ubuntu
MAINTAINER Mumie

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    PUID=\
    PGID=\
    DOWNLOAD_DIR=/sabnzbd/download \
    INCOMPLETE_DIR=/sabnzbd/incomplete \
    WATCH_DIR=

# Update packages and install software
RUN apt-get update \
    && apt-get -y install software-properties-common \
    && add-apt-repository multiverse \
    && add-apt-repository ppa:jcfp/ppa \
    && apt-get update \
    && apt-get install -y openvpn curl sudo rar unrar zip unzip wget sabnzbdplus \
    && curl -sLO https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb \
    && dpkg -i dumb-init_*.deb \
    && rm -rf dumb-init_*.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#    && curl -L https://github.com/jwilder/dockerize/releases/download/v0.0.2/dockerize-linux-amd64-v0.0.2.tar.gz | tar -C /usr/local/bin -xzv \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d /config -s /bin/false abc \
    && usermod -G users abc \
    && printf "USER=root\nHOST=0.0.0.0\nPORT=8080\nCONFIG=/config/sabnzbd-home\n" > /etc/default/sabnzbdplus \
    && /etc/init.d/sabnzbdplus start

ADD openvpn/ /etc/openvpn/
ADD scripts/ /scripts/
RUN chmod +x /etc/openvpn/start.sh \
    && chmod +x /scripts/*.sh


VOLUME /downloads
VOLUME /config

EXPOSE 8080 8090

CMD ["dumb-init", "/etc/openvpn/start.sh"]
