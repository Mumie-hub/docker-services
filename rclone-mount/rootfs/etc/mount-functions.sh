#!/usr/bin/env sh

# true if a FUSE filesystem is mounted exactly at $MountPoint
isRcloneMounted(){
    awk -v mp="${MountPoint}" '$2 == mp && $3 ~ /^fuse/ { found = 1 } END { exit !found }' /proc/mounts
}
