

SMB Mount Container based on `alpine:latest`
---




Lightweight and simple alpine Container Image with cifs-utils installed.


# Usage Example:

    docker run -d --name smb-mount \
        --restart=unless-stopped \
        --cap-add SYS_ADMIN \
        --cap-add DAC_READ_SEARCH \
        --security-opt apparmor:unconfined \
        -e SERVERPATH="//exampleserver/folder" \
        -e MOUNTOPTIONS="vers=3.02,uid=1000,gid=1000,rw,username=example,password=123example" \
        -v /mnt/HostMountPoint:/mnt/smb:shared \
        mumiehub/smb-mount


# USAGE Example:

    docker run -d --name smb-mount --restart=unless-stopped --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined -e SERVERPATH="//exampleserver/folder" -e MOUNTOPTIONS="vers=3.02,uid=1000,gid=1000,rw,username=example,password=123example" -v /mnt/HostMountPoint:/mnt/smb:shared mumiehub/smb-mount

> mendatory commands:

- --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined


> needed volume mappings:

- -v /mnt/HostMountPoint:/mnt/smb:shared

# Environment Variables:

```vim
-e AccessFolder="/mnt"
"access test

-e SERVERPATH="//192.168.1.1/example"
"SMB Server Hostname or IP

-e MOUNTPOINT="/mnt/smb" "INSIDE Container: needs to match volume mapping -v /mnt/HostMountPoint:/mnt/smb:shared

-e MOUNTOPTIONS="vers=3.02,uid=1000,gid=1000,rw,username=exaple,password=123example"
"Mount Commands with Username and Password

-e UMOUNTOPTIONS="-a -t cifs -l"
```


## Troubleshooting:
When you force remove the container, you have to `sudo umount /mnt/smb` on the hostsystem!

Mounting Windows Server 2016 SMB share works with `MOUNTOPTIONS="vers=3.02"`!



Todo
----

* [ ] more settings
* [ ] more specific FAQ and Troubleshooting help
* [ ] launch with specific USER_ID

## License

See [LICENSE](LICENSE)