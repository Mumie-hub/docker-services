# SABnzbd and OpenVPN

Docker container which runs SABnzbd while connected to OpenVPN.

## Run container from Docker registry
To run the container use this command for example:

```
docker run -d --name sabnzbd_vpn \
            -v /your/storage/path:/data \
            -v /path/to/ovpn-file:/etc/openvpn/custom
            -v /etc/localtime:/etc/localtime:ro \
            -e "LOCAL_NETWORK=192.168.0.0/24" \
            -p 8080:8080 \
            mumie/sabnzbdvpn
```



### Environment options passed with docker -e
| Variable | Function | Notes |
|----------|----------|----------|
|`OPENVPN_CONFIG_DIR` |OpenVPN config dir. | Default is `"/etc/openvpn/custom"` needs to match mappings. |
|`OPENVPN_CONFIG`|OpenVPN config filename | Default name is `default.ovpn`|
|`SABNZBD_CONFIG_DIR`|SABnzbd data dir |#inside Container. default `"/config"`, needs to match hostmountpoint|
|`DOWNLOAD_DIR`|SABnzbd download dir|#inside Container. This is where SABnzbd will store your downloads. Default `"/tmp/media/downloads"`|
|`INCOMPLETE_DIR`|SABnzbd incomplete dir|inside the Container. This is where SABnzbd will store your incomplete downloads|


### Network configuration options
| Variable | Function | Example |
|----------|----------|---------|
|`OPENVPN_OPTS` | Will be passed to OpenVPN on startup | See [OpenVPN doc](https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html) |
|`LOCAL_NETWORK` | Sets the local network that should have access to the GUI | `LOCAL_NETWORK=192.168.0.0/24`|


#### User configuration options

By default OpenVPN will run as the root user and SABnzbd will run as user abc `1003:1003`. You may set the following parameters to customize the user id that runs SABnzbd.

| Variable | Function | Example |
|----------|----------|-------|
|`-e PUID` | Sets the user id who will run SABnzbd | Default = `PUID=1003`|
|`-e PGID` | Sets the group id for the SABnzbd user | Default = `PGID=1003` |


## Access the WebUI of SABnzbd

If you set `LOCAL_NETWORK` correctly, the WebUI of SABnzbd should be at http://containerhost:8080. If its not responding, there might be an error with your 
`LOCAL_NETWORK` subnet settings.

### How to fix this:
The container supports the `LOCAL_NETWORK` environment variable. For instance if your local network uses the subnet 192.168.0.0/24 you should pass `-e LOCAL_NETWORK=192.168.0.0/24`. It must match your subnet, else your traffic will be "non-local" traffic and therefore be routed out through the VPN interface.

Alternatively you can reverse proxy the traffic through another container, as that container would be in the docker range. 

```
$ docker run -d \
      --link <sabnzbdvpn-containername> \
      -p 8080:8080 \
      nginx:latest
```

## Tips and Tricks

### Using your ovpn config file

Add a new volume mount to your `docker run` command that mounts your config file:

    -v /path/to/config.ovpn:/etc/openvpn/custom/default.ovpn

If you have an separate ca.crt file your volume mount should be a folder containing both the ca.crt and the .ovpn config.

#### Use Google DNS servers
Some have encountered problems with DNS resolving inside the docker container.
This causes trouble because OpenVPN will not be able to resolve the host to connect to.
If you have this problem use dockers --dns flag to override the resolv.conf of the container.
For example use googles dns servers by adding --dns 8.8.8.8 --dns 8.8.4.4 as parameters to the usual run command.

#### Restart container if connection is lost
If the VPN connection fails or the container for any other reason loses connectivity, you want it to recover from it. One way of doing this is to set environment variable `OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60` and use the --restart=always flag when starting the container. This way OpenVPN will exit if ping fails over a period of time which will stop the container and then the Docker deamon will restart it.

#### Wrong link mtu

When your are using a managed network layer for example, the default link mtu of 1500 can be to big. Setting a lower mtu in OpenVPN should help:
`-e OPENVPN_OPTS --tun-mtu 1300`
