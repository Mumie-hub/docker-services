FROM alpine
MAINTAINER Mumie

ENV GOPATH="/go" \
    AccessFolder="/mnt" \
    RemotePath="mediaefs:" \
    MountPoint="/mnt/mediaefs" \
    ConfigDir="/config" \
    ConfigName=".rclone.conf" \
    MountCommands="--allow-other --allow-non-empty --dir-cache-time 30m"

## Alpine with Go Git
RUN apk add --no-cache --update alpine-sdk ca-certificates go git fuse \
	&& go get -u -v github.com/ncw/rclone \
	&& cp /go/bin/rclone /usr/sbin/ \
	&& rm -rf /go \
	&& apk del alpine-sdk go git \
	&& rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

ADD start.sh /start.sh
RUN chmod +x /start.sh 

VOLUME [$AccessFolder]

CMD ["/start.sh"]

# Use this args in docker run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfine
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared