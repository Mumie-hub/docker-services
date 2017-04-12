<h1 align="center">
  <img src="https://rclone.org/img/rclone-120x120.png" alt="vim-devicons">
</h1>

Rclone Mount Container Image (**`40MB`**) based on `alpine:latest`
---




Lightweight Container with compiled rclone (https://github.com/ncw/rclone master), to mount your cloudstorage like amazon cloud drive inside a container and make it available to other containers like your Plex Media Server or on your hostsystem (mountpoint on host is shared). You need a working rclone.conf first (from other host). rclone crypt remote can also be used.


The Container uses a trap_handler script to handle docker stop/restart or rclone crashes ( fusermount -u $MountPoint is applied on crash or SIGTERM) on PID 1.

<a name="install-step1"></a>
## USAGE:

    docker run -d --name rclone-mount --restart=unless-stopped --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined -e RemotePath="mediaefs:" -e MountCommands="--allow-other --allow-non-empty --dir-cache-time 30m" -v /home/USER/.rclone.conf:/config/.rclone.conf -v /mnt/HostMountPoint:/mnt/mediaefs:shared mumiehub/rclone-mount

> needed volume mappings:

- -v /home/USER/.rclone.conf:/config/.rclone.conf
- -v /mnt/HostMountPoint:/mnt/mediaefs:shared mumiehub/rclone-mount

## Environment Variables:

```vim
-e AccessFolder="/mnt"
"access from other containers with --volumes-from rclone-mount or -v /mnt:/mnt:slave changes of AccessFolder have no impact because its the exposed folder in the dockerfile so --volumes-from rclone-mount is always /mnt


-e RemotePath="mediaefs:" "#remote name in your rclone config, can be your crypt remote:/path

-e MountPoint="/mnt/mediaefs" "#INSIDE Container from rclone: needs to match volume mapping -v /mnt/HostMountPoint:/mnt/mediaefs:shared

-e ConfigDir="/config" "#INSIDE Container: -v /home/USER/.rclone.conf:/config/.rclone.conf
-e ConfigName=".rclone.conf" "#INSIDE Container: -v /home/USER/.rclone.conf:/config/.rclone.conf

-e MountCommands="--allow-other --allow-non-empty --dir-cache-time 30m"
"default mount commands, (if you not parse any with -e MountCommands=<xxx>, default will be used)
```


### Use your own MountCommands with:
    -e MountCommands="--allow-other --allow-non-empty --dir-cache-time 30m --buffer-size 64M"
All Commands can be found at: `https://rclone.org/commands/rclone_mount/`.
Use --buffer-size 64M (dont go to high) when you encounter some "Direct Stream" Problems on Plex Media Server (Samsung Smart TV for example).

## Troubleshooting:
When you force remove the container, you have to sudo fusermount -u /mnt/mediaefs on the hostsystem!



Todo
----

* [ ] more settings
* [ ] more specific FAQ and Troubleshooting help
* [ ] Auto Update Function

## License

See [LICENSE](LICENSE)