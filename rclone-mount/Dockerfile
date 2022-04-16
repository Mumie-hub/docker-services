ARG RCLONE_VERSION="v1.58.0"
ARG OVERLAY_VERSION="v2.2.0.3"
ARG OVERLAY_ARCH="amd64"
ARG OVERLAY_KEY="6101B2783B2FD161"


# Builder
FROM golang:alpine AS builder

ARG RCLONE_VERSION

WORKDIR /go/src/github.com/rclone/rclone/

ENV GOPATH="/go" \
    GO111MODULE="on"

RUN apk add --no-cache --update ca-certificates go git \
    && git clone https://github.com/rclone/rclone.git \
    && cd rclone \
    && git checkout tags/${RCLONE_VERSION} \
    && go build


## Image
FROM alpine:latest

ARG OVERLAY_VERSION
ARG OVERLAY_ARCH
ARG OVERLAY_KEY

ENV DEBUG="false" \
    AccessFolder="/mnt" \
    RemotePath="mediaefs:" \
    MountPoint="/mnt/mediaefs" \
    ConfigDir="/config" \
    ConfigName=".rclone.conf" \
    MountCommands="--allow-other --allow-non-empty" \
    UnmountCommands="-u -z"

COPY --from=builder /go/src/github.com/rclone/rclone/rclone /usr/local/sbin/

RUN apk --no-cache upgrade \
    && apk add --no-cache --update ca-certificates fuse fuse-dev curl gnupg \
    && echo "Installing S6 Overlay" \
    && curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
    && curl -o /tmp/s6-overlay.tar.gz.sig -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz.sig" \
    && gpg --keyserver pgp.surfnet.nl --recv-keys ${OVERLAY_KEY} \
    && gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz \
    && tar xzf /tmp/s6-overlay.tar.gz -C / \
    && apk del curl gnupg \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

COPY rootfs/ /

VOLUME ["/mnt"]

ENTRYPOINT ["/init"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared
