#!/usr/bin/with-contenv sh

. /etc/mount-functions.sh

isRcloneMounted || exit 1

# a crashed rclone leaves the mount behind with "transport endpoint is not connected"
stat "${MountPoint}" > /dev/null 2>&1 || exit 1

exit 0
