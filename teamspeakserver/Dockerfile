# -------------------------------------------------------------------------------
# Builds a basic docker alpine image that can run TeamSpeak of a folder
#
# MAINTAINER: Mumie
# Updated: January 31th, 2017
# -------------------------------------------------------------------------------

FROM alpine

MAINTAINER Mumie

ENV USER_NAME="teamspeak" \
    USER_UID="1001" \
    DATA_DIR="/teamspeak" \
    TS_VERSION="LATEST"

RUN apk add --no-cache --update bzip2 ca-certificates openssl python3 \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
#    && apk add --no-cache -X http://apkproxy.heroku.com/andyshinn/alpine-pkg-glibc glibc glibc-bin \
#   apkproxy.heroku.com/andyshinn proxy broken
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk \
    && apk add glibc-2.25-r0.apk \
    && adduser -D -u ${USER_UID} -s /bin/false $USER_NAME \
    && apk del openssl ca-certificates \
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