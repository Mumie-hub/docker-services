[rcloneurl]: https://rclone.org

[![rclone.org](https://rclone.org/img/logo_on_dark__horizontal_color.svg)][rcloneurl]

## Rclone Mount Container

Lightweight and simple Container Image (`alpine:latest - 77 MiB`) with compiled rclone (https://github.com/rclone/rclone). Mount your cloud storage like google drive inside a container and make it available to other containers like your Plex Server or on your hostsystem (mount namespace on the host is shared). The remotes come from an rclone.conf in the config volume (from another host or create it inside the container with entrypoint /bin/sh) or from environment variables, see [Configuration without rclone.conf](#configuration-without-rcloneconf). all rclone remotes can be used.

The Container uses S6 Overlay, to handle docker stop/restart ( fusermount -uz $MountPoint is applied on app crashes also) and also preparing the mountpoint.

# Images:

| Registry                  | Image                            | Architectures  |
| ------------------------- | -------------------------------- | -------------- |
| Docker Hub                | `mumiehub/rclone-mount`          | amd64          |
| GitHub Container Registry | `ghcr.io/mumie-hub/rclone-mount` | amd64, arm64   |

Tags:

- `latest`, `v1.75` and `v1.75.2`: newest build for that rclone version, they move when the image is rebuilt
- `v1.75.2-<commit>` (e.g. `v1.75.2-fa84c0e1`): one fixed build, use this to pin an exact image
- `dev`, `dev-<version>` and `dev-<commit>`: development builds, don't use them in production

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

- -v /host/mount/point:/mnt/mediaefs:shared
- -v /path/to/config:/config (not needed when the remote is configured with environment variables)

# Configuration without rclone.conf:

rclone can read remotes from environment variables (`RCLONE_CONFIG_<NAME>_<OPTION>`, see [rclone docs](https://rclone.org/docs/#config-file)), e.g. from a Kubernetes secret or an env file. The config volume is optional then:

    docker run -d --name rclone-mount \
        --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor=unconfined \
        -e RemotePath="mys3:bucket" \
        -e RCLONE_CONFIG_MYS3_TYPE=s3 \
        -e RCLONE_CONFIG_MYS3_PROVIDER=AWS \
        -e RCLONE_CONFIG_MYS3_ACCESS_KEY_ID=... \
        -e RCLONE_CONFIG_MYS3_SECRET_ACCESS_KEY=... \
        -v /host/mount/point:/mnt/mediaefs:shared \
        mumiehub/rclone-mount

A connection string works too, e.g. `RemotePath=":s3,provider=AWS,env_auth:bucket"`. The container logs a warning when there is no config file and no `RCLONE_CONFIG_*_TYPE` variable, rclone then fails to mount if the remote is unknown.

OAuth remotes (Google Drive etc.) refresh their token while running, rclone can only save it to a config file, so a config file is the safer choice for them.

# Environment Variables:

| Variable                                          |     | Description                                                                                                                       |
| ------------------------------------------------- | --- | --------------------------------------------------------------------------------------------------------------------------------- |
| `RemotePath`="mediaefs:path"                      |     | remote name in your rclone config or environment variables, can be your crypt remote: + path/foo/bar, or a connection string      |
| `MountPoint`="/mnt/mediaefs"                      |     | #INSIDE Container: needs to match mapping -v /host/mount/point:`/mnt/mediaefs:shared`                                             |
| `ConfigDir`="/config"                             |     | #INSIDE Container: -v /path/to/config:/config                                                                                     |
| `ConfigName`=".rclone.conf"                       |     | #INSIDE Container: /config/.rclone.conf                                                                                           |
| `MountCommands`="--allow-other --allow-non-empty" |     | default mount commands (used if you don't pass your own)                                                                          |
| `UnmountCommands`="-u -z"                         |     | default unmount commands                                                                                                          |
| `AutoUpgrade`="false"                             |     | set to `true` to run `apk upgrade` on every container start                                                                       |
| `S6_KILL_FINISH_MAXTIME`="6000"                   |     | time in ms for the unmount on shutdown, rclone gets this minus 2s to unmount itself, the rest is left for the forced unmount      |
| `S6_SERVICES_GRACETIME`="1000"                    |     | time in ms s6 waits for the services to stop after the unmount                                                                    |
| `S6_KILL_GRACETIME`="1000"                        |     | time in ms between TERM and KILL for the remaining processes at the end of the shutdown                                           |
| `S6_BEHAVIOUR_IF_STAGE2_FAILS`="2"                |     | `2` stops the container when a start check fails (missing config, stale mount), `0` ignores it and starts rclone anyway           |

## Shutdown

rclone needs time to unmount cleanly. The shutdown takes up to `S6_KILL_FINISH_MAXTIME` + `S6_SERVICES_GRACETIME` + `S6_KILL_GRACETIME` + about 0.5s, with the defaults about 8.5s, so it fits into the docker default stop timeout of 10s. If the container is killed before, the mount stays behind on the host.

If rclone needs longer (e.g. pending uploads with `--vfs-cache-mode writes`), raise `S6_KILL_FINISH_MAXTIME` and give the container a stop timeout about 3s above it:

- docker: `-e S6_KILL_FINISH_MAXTIME=20000 --stop-timeout 23`
- compose: `S6_KILL_FINISH_MAXTIME: "20000"` and `stop_grace_period: 23s`
- Kubernetes: `S6_KILL_FINISH_MAXTIME: "20000"` and `terminationGracePeriodSeconds: 23`

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
