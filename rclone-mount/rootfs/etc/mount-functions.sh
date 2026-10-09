#!/usr/bin/env sh

# true if a FUSE filesystem is mounted exactly at $MountPoint
isRcloneMounted(){
    awk -v mp="${MountPoint}" '$2 == mp && $3 ~ /^fuse/ { found = 1 } END { exit !found }' /proc/mounts
}

# true if the FUSE mount at $MountPoint sits on a shared mount, so unmounting it here also removes it on the host.
# false if the FUSE mount is the volume bind itself (dead mount on the host used as bind source).
hasSharedParent(){
    awk -v mp="${MountPoint}" '
        {
            line[$1] = $0
            split($0, part, " - ")
            if ($5 == mp && part[2] ~ /^fuse/) parent = $2
        }
        END {
            if (parent == "") exit 1
            split(line[parent], part, " - ")
            exit !(part[1] ~ / shared:/)
        }' /proc/self/mountinfo
}

# true if $MountPoint lives on a shared mount, required for the host and other containers to see the rclone mount
isMountPointShared(){
    awk -v mp="${MountPoint}" '
        {
            split($0, part, " - ")
            if ($5 == mp && part[2] ~ /^fuse/) next
            if (($5 == mp || $5 == "/" || index(mp, $5 "/") == 1) && length($5) >= best) {
                best = length($5)
                shared = (part[1] ~ / shared:/)
            }
        }
        END { exit !shared }' /proc/self/mountinfo
}
