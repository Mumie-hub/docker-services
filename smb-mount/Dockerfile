FROM alpine
#MAINTAINER Mumie

ENV SERVERPATH="//192.168.1.1/example" \
    MOUNTPOINT="/mnt/smb" \
    MOUNTOPTIONS="" \
    UMOUNTOPTIONS="-a -t cifs -l" \
    AccessFolder="/mnt"

## Alpine with cifs-utils
RUN apk add --no-cache --update cifs-utils \
    && mkdir $MOUNTPOINT \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

ADD start.sh /start.sh
RUN chmod +x /start.sh

#VOLUME ["/mnt"]

CMD ["/start.sh"]

# Use this args in docker run
# --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfine