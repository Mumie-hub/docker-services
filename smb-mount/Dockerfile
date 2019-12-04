FROM alpine:latest

ARG OVERLAY_VERSION="v1.22.1.0"
ARG OVERLAY_ARCH="amd64"

ENV DEBUG="false" \
    SERVERPATH="//192.168.1.1/example" \
    MOUNTPOINT="/mnt/smb" \
    MOUNTOPTIONS="vers=3.1.1,uid=1000,gid=1000,file_mode=0774,dir_mode=0775,rw,username=user,password=password" \
    UMOUNTOPTIONS="-a -t cifs -l" \
    AccessFolder="/mnt"

RUN apk --no-cache upgrade \
    && apk add --no-cache --update cifs-utils bash tar curl ca-certificates gnupg grep \
    && curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
    && curl -o /tmp/s6-overlay.tar.gz.sig -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz.sig" \
    && curl https://keybase.io/justcontainers/key.asc | gpg --import \
    && gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz \
    && tar xfz /tmp/s6-overlay.tar.gz -C / \
    && apk del tar curl gnupg \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

# add local files
COPY rootfs/ /

#VOLUME ["/mnt"]

ENTRYPOINT ["/init"]

# HEALTHCHECK --interval=5s --timeout=2s --retries=20 CMD /healthcheck.sh || exit 1
# Use this args in docker run
# --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined