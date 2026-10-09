[rcloneurl]: https://rclone.org

[![rclone.org](https://rclone.org/img/logo_on_dark__horizontal_color.svg)][rcloneurl]

## Rclone Mount Container

Lightweight and simple Container Image (`alpine:latest - 77 MiB`) with compiled rclone (https://github.com/rclone/rclone). Mount your cloud storage like google drive inside a container and make it available to other containers like your Plex Server or on your hostsystem (mount namespace on the host is shared). You need a working rclone.conf (from another host or create it inside the container with entrypoint /bin/sh). all rclone remotes can be used.

The Container uses S6 Overlay, to handle docker stop/restart ( fusermount -uz $MountPoint is applied on app crashes also) and also preparing the mountpoint.

# Usage Example:

    docker run -d --name rclone-mount \
        --restart=unless-stopped \
        --cap-add SYS_ADMIN \
        --device /dev/fuse \
        --security-opt apparmor=unconfined \
        -e RemotePath="mediaefs:" \
        -e MountCommands="--allow-other --allow-non-empty" \
        -v /path/to/config:/config \
        -v /host/mount/point:/mnt/mediaefs:shared \
        mumiehub/rclone-mount

> mandatory docker commands:

- --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor=unconfined

> needed volume mappings:

- -v /path/to/config:/config
- -v /host/mount/point:/mnt/mediaefs:shared

# Environment Variables:

| Variable                                          |     | Description                                                                                                                       |
| ------------------------------------------------- | --- | --------------------------------------------------------------------------------------------------------------------------------- |
| `RemotePath`="mediaefs:path"                      |     | remote name in your rclone config, can be your crypt remote: + path/foo/bar                                                       |
| `MountPoint`="/mnt/mediaefs"                      |     | #INSIDE Container: needs to match mapping -v /host/mount/point:`/mnt/mediaefs:shared`                                             |
| `ConfigDir`="/config"                             |     | #INSIDE Container: -v /path/to/config:/config                                                                                     |
| `ConfigName`=".rclone.conf"                       |     | #INSIDE Container: /config/.rclone.conf                                                                                           |
| `MountCommands`="--allow-other --allow-non-empty" |     | default mount commands (used if you don't pass your own)                                                                          |
| `UnmountCommands`="-u -z"                         |     | default unmount commands                                                                                                          |
| `AutoUpgrade`="false"                             |     | set to `true` to run `apk upgrade` on every container start                                                                       |
| `S6_KILL_FINISH_MAXTIME`="6000"                   |     | time in ms rclone gets to unmount on shutdown, keep the docker stop timeout about 3s above this value                             |

## Shutdown

rclone needs time to unmount cleanly. The defaults fit into the docker default stop timeout of 10s. If rclone needs longer (e.g. pending uploads), raise `S6_KILL_FINISH_MAXTIME` and give the container a stop timeout about 3s above it (e.g. `-e S6_KILL_FINISH_MAXTIME=20000 --stop-timeout 23` or `stop_grace_period: 23s` in compose), otherwise docker kills it and the mount stays behind on the host.

## Healthcheck

The image reports unhealthy when the mount is missing or rclone crashed and left a dead mount behind.

## Use your own MountCommands with:

```sh
-e MountCommands="--allow-other --allow-non-empty --dir-cache-time 48h --poll-interval 5m --buffer-size 128M"
```

All Commands can be found at [https://rclone.org/commands/rclone_mount/](https://rclone.org/commands/rclone_mount/). Use `--buffer-size 256M` (don't go too high) when you encounter "Direct Stream" problems on Plex Server for example.

## Troubleshooting:

The mount is only removed from the host while the container is still running. If the container is killed (stop timeout exceeded, `docker kill`, docker daemon crash), a dead mount stays behind on the host and docker cannot start the container again until you run `sudo fusermount -u -z /host/mount/point` on the hostsystem!

Other containers using the mount (Plex etc.) need the volume with `:rslave` (e.g. `-v /host/mount/point:/media:rslave`), otherwise they do not see the mount when rclone mounts after them or remounts after a restart.

## Todo

- [ ] more settings
- [ ] Auto Update Function
- [ ] launch with specific USER_ID
