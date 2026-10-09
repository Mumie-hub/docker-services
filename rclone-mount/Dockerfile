ARG IMAGE_VERSION="v1.69.1"
ARG OVERLAY_VERSION="v2.2.0.3"
ARG OVERLAY_ARCH="amd64"
ARG OVERLAY_KEY="6101B2783B2FD161"


# Builder
FROM golang:alpine AS builder

ARG IMAGE_VERSION

WORKDIR /go/src/github.com/rclone/rclone/

ENV GOPATH="/go" \
    GO111MODULE="on" \
    GOMAXPROCS="2" \
    GOMEMLIMIT="4GiB"

RUN apk add --no-cache --update ca-certificates go git \
    && git clone --depth 1 --branch ${IMAGE_VERSION} https://github.com/rclone/rclone.git \
    && cd rclone \
    && go build \
    && rm -rf /root/.cache /go/pkg .git


# Image
FROM alpine:latest

ARG OVERLAY_VERSION
ARG OVERLAY_ARCH
ARG OVERLAY_KEY
ARG TARGETARCH

ENV DEBUG="false" \
    AccessFolder="/mnt" \
    RemotePath="mediaefs:" \
    MountPoint="/mnt/mediaefs" \
    ConfigDir="/config" \
    ConfigName=".rclone.conf" \
    MountCommands="--allow-other --allow-non-empty" \
    UnmountCommands="-u -z" \
    AutoUpgrade="false" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
    S6_KILL_FINISH_MAXTIME="30000" \
    S6_SERVICES_GRACETIME="5000"

COPY --from=builder /go/src/github.com/rclone/rclone/rclone/rclone /usr/local/sbin/

RUN apk --no-cache upgrade \
    && apk add --no-cache --update ca-certificates fuse3 fuse curl gnupg \
    && case "${TARGETARCH:-amd64}" in \
        "amd64") OVERLAY_ARCH="amd64" ;; \
        "arm64") OVERLAY_ARCH="aarch64" ;; \
        "arm") OVERLAY_ARCH="arm" ;; \
        *) OVERLAY_ARCH="${OVERLAY_ARCH:-amd64}" ;; \
    esac \
    && echo "Installing S6 Overlay (${OVERLAY_ARCH})" \
    && curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
    && curl -o /tmp/s6-overlay.tar.gz.sig -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz.sig" \
    && (gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys ${OVERLAY_KEY} || gpg --keyserver pgp.surfnet.nl --recv-keys ${OVERLAY_KEY}) \
    && gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz \
    && tar xzf /tmp/s6-overlay.tar.gz -C / \
    && apk del curl gnupg \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

COPY rootfs/ /

VOLUME ["/mnt"]

HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 CMD ["/healthcheck.sh"]

ENTRYPOINT ["/init"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined --stop-timeout 45
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared
