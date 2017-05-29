

SMB Mount Container based on `alpine:latest`
---




Lightweight and simple alpine Container Image with cifs-utils installed.

# USAGE Example:

    docker run -d --name smb-mount --restart=unless-stopped --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined -e SERVERPATH="//exampleserverIP/example" -v /mnt/HostMountPoint:/mnt/smb:shared mumiehub/smb-mount

> mendatory commands:

- --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined


> needed volume mappings:

- -v /mnt/HostMountPoint:/mnt/smb:shared

# Environment Variables:

```vim
-e AccessFolder="/mnt"
"access test

-e SERVERPATH="//192.168.1.1/example"
"remote SMB Server Path

-e MountPoint="/mnt/smb" "INSIDE Container: needs to match volume mapping -v /mnt/HostMountPoint:/mnt/smb:shared

-e MountCommands=""
"default is empty
```


## Troubleshooting:
When you force remove the container, you have to `sudo umount /mnt/smb` on the hostsystem!



Todo
----

* [ ] more settings
* [ ] more specific FAQ and Troubleshooting help
* [ ] launch with specific USER_ID

## License

See [LICENSE](LICENSE)