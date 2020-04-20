
SMB Mount Container based on `alpine:latest`
---


Lightweight and simple alpine container image with cifs-utils installed.


# Usage Example:

    docker run -d --name smb-mount \
        --restart=unless-stopped \
        --cap-add SYS_ADMIN \
        --cap-add DAC_READ_SEARCH \
        --security-opt apparmor:unconfined \
        -e SERVERPATH="//exampleserver/folder" \
        -e MOUNTOPTIONS="vers=3.1.1,uid=1000,gid=1000,rw,username=user,password=example" \
        -v /mnt/HostMountPoint:/mnt/smb:shared \
        mumiehub/smb-mount
---
    docker run -d --name smb-mount --restart=unless-stopped --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined -e SERVERPATH="//exampleserver/folder" -e MOUNTOPTIONS="vers=3.1.1,uid=1000,gid=1000,rw,username=user,password=example" -v /mnt/HostMountPoint:/mnt/smb:shared mumiehub/smb-mount


> mendatory commands:

- --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --security-opt apparmor:unconfined


> needed volume mappings:

- -v /mnt/HostMountPoint:/mnt/smb:shared


# Environment Variables:

```vim
AccessFolder="/mnt"
"access test

SERVERPATH="//192.168.1.1/example"
"SMB Server Hostname or IP

MOUNTPOINT="/mnt/smb" "INSIDE Container: needs to match volume mapping -v /mnt/HostMountPoint:/mnt/smb:shared

MOUNTOPTIONS="vers=3.1.1,uid=1000,gid=1000,rw,username=user,password=example"
"Mount Commands with Username and Password

UMOUNTOPTIONS="-a -t cifs -l"
```


### Set Folder Permissions:
```
MOUNTOPTIONS="vers=3.1.1,uid=1000,gid=1000,file_mode=0755,dir_mode=0755,rw,username=user,password=example"
```

## Troubleshooting:
When you force remove the container, you have to `sudo umount /mnt/smb` on the hostsystem!

Mounting Windows Server 2016 SMB shares works with `MOUNTOPTIONS="vers=3.02"`!



Todo
----

* [ ] more settings
* [ ] more specific FAQ and Troubleshooting help
* [ ] launch with specific USER_ID

## License

See [LICENSE](LICENSE)