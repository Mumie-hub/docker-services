FROM ubuntu:latest

ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    USER_NAME="abc" \
    PUID=1003 \
    PGID=1003 \
#    OPENVPN_USERNAME="" \
#    OPENVPN_PASSWORD="" \
    OPENVPN_CONFIG_DIR="/etc/openvpn/custom" \
    OPENVPN_CONFIG="default.ovpn" \
    SABNZBD_CONFIG_DIR="/config" \
    DOWNLOAD_DIR="/tmp/media/downloads" \
    INCOMPLETE_DIR="/tmp/media/incomplete" \
    WATCH_DIR=""

RUN apt-get update \
    && apt-get -y install software-properties-common nano \
    && add-apt-repository ppa:jcfp/ppa \
    && add-apt-repository ppa:jcfp/sab-addons \
    && apt-get update \
    && apt-get install -y openvpn curl sudo sabnzbdplus wget par2-tbb python-sabyenc p7zip-full locales \
    && locale-gen en_US.UTF-8 \
    && curl -sLO https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64.deb \
    && dpkg -i dumb-init_*.deb \
    && rm -rf dumb-init_*.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && groupmod -g 1000 users \
    && mkdir -p /home/${USER_NAME} \
    && useradd -u ${PUID} -U -d /home/${USER_NAME} -s /bin/false ${USER_NAME} \
    && usermod -G users ${USER_NAME}

    # deprecated and modified from other github repo
    #&& printf "USER=root\nHOST=0.0.0.0\nPORT=8080\nCONFIG=/config\n" > /etc/default/sabnzbdplus \
    #&& /etc/init.d/sabnzbdplus start

ADD openvpn/ /etc/openvpn/
ADD scripts/ /scripts/
RUN chmod +x /etc/openvpn/start.sh \
    && chmod +x /scripts/*.sh

VOLUME $DOWNLOAD_DIR
#VOLUME /config

EXPOSE 8080 8090

CMD ["dumb-init", "/etc/openvpn/start.sh"]
