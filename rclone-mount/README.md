[rcloneurl]: https://rclone.org

[![rclone.org](https://rclone.org/img/logo_on_dark__horizontal_color.svg)][rcloneurl]

Rclone Mount Container
---

Lightweight and simple Container Image (`alpine:latest - 117MB`) with compiled rclone (https://github.com/ncw/rclone). Mount your cloud storage like google drive inside a container and make it available to other containers like your Plex Server or on your hostsystem (mount namespace on the host is shared). You need a working rclone.conf (from another host or create it inside the container with entrypoint /bin/sh). all rclone remotes can be used.


The Container uses S6 Overlay, to handle docker stop/restart ( fusermount -uz $MountPoint is applied on app crashes also) and also preparing the mountpoint.


# Usage Example:

    docker run -d --name rclone-mount \
        --restart=unless-stopped \
        --cap-add SYS_ADMIN \
        --device /dev/fuse \
        --security-opt apparmor:unconfined \
        -e RemotePath="mediaefs:" \
        -e MountCommands="--allow-other --allow-non-empty" \
        -v /path/to/config:/config \
        -v /host/mount/point:/mnt/mediaefs:shared \
        mumiehub/rclone-mount


> mandatory docker commands:

- --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined


> needed volume mappings:

- -v /path/to/config:/config
- -v /host/mount/point:/mnt/mediaefs:shared


# Environment Variables:

| Variable |  | Description |
|---|--------|----|
|`RemotePath`="mediaefs:path" | |remote name in your rclone config, can be your crypt remote: + path/foo/bar|
|`MountPoint`="/mnt/mediaefs"| |#INSIDE Container: needs to match mapping -v /host/mount/point:`/mnt/mediaefs:shared`|
|`ConfigDir`="/config"| |#INSIDE Container: -v /path/to/config:/config|
|`ConfigName`=".rclone.conf"| |#INSIDE Container: /config/.rclone.conf|
|`MountCommands`="--allow-other --allow-non-empty"| |default mount commands, (if you not parse anything, defaults will be used)|
|`UnmountCommands`="-u -z"| |default unmount commands|
|`AccessFolder`="/mnt" ||access with --volumes-from rclone-mount, changes of AccessFolder have no impact because its the exposed folder in the dockerfile.|


## Use your own MountCommands with:
```vim
-e MountCommands="--allow-other --allow-non-empty --dir-cache-time 48h --poll-interval 5m --buffer-size 128M"
```

All Commands can be found at [https://rclone.org/commands/rclone_mount/](https://rclone.org/commands/rclone_mount/). Use `--buffer-size 256M` (dont go too high), when you encounter some "Direct Stream" problems on Plex Server for example.

## Troubleshooting:
When you force remove the container, you have to `sudo fusermount -u -z /host/mount/point` on the hostsystem!



Todo
----

* [ ] more settings
* [ ] Auto Update Function
* [ ] launch with specific USER_ID
