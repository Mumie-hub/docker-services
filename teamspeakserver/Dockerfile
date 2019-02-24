# -------------------------------------------------------------------------------
# Builds a basic docker alpine image that can run TeamSpeak from a folder
#
# Updated: Nov 09, 2017
# -------------------------------------------------------------------------------

FROM alpine

ENV USER_NAME="teamspeak" \
    USER_UID="1001" \
    DATA_DIR="/teamspeak" \
    TS_VERSION="LATEST" \
    GLIBC_VERSION=2.28-r0

RUN apk add --no-cache --update bzip2 ca-certificates openssl python3 \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    && apk add glibc-${GLIBC_VERSION}.apk \
    && adduser -D -u ${USER_UID} -s /bin/false $USER_NAME \
    && apk del openssl \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

ADD start.sh /start.sh
ADD get-version.py /get-version.py
RUN chmod +x /start.sh \
    && chmod +x /get-version.py

#VOLUME ["/teamspeak"]
EXPOSE 9987/udp 30033 10011

#CMD ["/teamspeak/ts3server", "-LD_LIBRARY_PATH=/teamspeak"]

USER $USER_NAME

CMD ["/start.sh"]