FROM ubuntu:focal

ARG DUMB_INIT_VERSION="1.2.5"
ARG DUMB_INIT_ARCH="amd64"

ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
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
    && apt-get install -y software-properties-common sudo curl wget nano locales python3-sabyenc python3-chardet p7zip-full unzip \
    && add-apt-repository ppa:jcfp/ppa \
    && add-apt-repository ppa:jcfp/sab-addons \
    && echo "install openvpn and sabnzbdplus packages" \
    && apt-get install -y openvpn sabnzbdplus par2-tbb \
    && locale-gen en_US.UTF-8 \
    && curl -sLO https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_${DUMB_INIT_ARCH}.deb \
    && dpkg -i dumb-init_*.deb \
    && rm -rf dumb-init_*.deb \
    && echo "cleanup tasks" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && groupmod -g 1000 users \
    && mkdir -p /home/${USER_NAME} \
    && useradd -u ${PUID} -U -d /home/${USER_NAME} -s /bin/false ${USER_NAME} \
    && usermod -G users ${USER_NAME}

ADD openvpn/ /etc/openvpn/
ADD scripts/ /scripts/
RUN chmod +x /etc/openvpn/start.sh \
    && chmod +x /scripts/*.sh

VOLUME $DOWNLOAD_DIR $SABNZBD_CONFIG_DIR

EXPOSE 8080 8090

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/etc/openvpn/start.sh"]
