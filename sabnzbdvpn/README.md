# SABnzbd and OpenVPN
Docker container which runs SABnzbd while connected to OpenVPN.

## Run container from Docker registry
The container is available from the Docker registry.
To run the container use this command:

```
$ docker run -d --name CONTAINER_NAME \
              -v /your/storage/path/:/data \
              -v /path/to/ovpn-file:/etc/openvpn/custom
              -v /etc/localtime:/etc/localtime:ro \
              -e "OPENVPN_PROVIDER=CUSTOM" \
              -e "LOCAL_NETWORK=192.168.0.0/24" \
              -p 8080:8080 \
              mumie/sabnzbdvpn
```



### Required environment options passed with -e
| Variable | Function | Notes |
|----------|----------|----------|
|`OPENVPN_CONFIG_DIR` | Sets the OpenVPN config dir. | `test`. and their config values are listed in the table above. |
|`OPENVPN_CONFIG`|Your OpenVPN config filename | Default name is `default.ovpn`|
|`SABNZBD_CONFIG_DIR`|Your SABnzbd data dir | inside the Container. at /config, `needs to match hostmountpoint`|
|`DOWNLOAD_DIR`|SABnzbd download dir|inside the Container. This is where SABnzbd will store your downloads and incomplete downloads|
|`INCOMPLETE_DIR`|SABnzbd incomplete dir|inside the Container. This is where SABnzbd will store your downloads and incomplete downloads|


#### Network configuration options
| Variable | Function | Example |
|----------|----------|---------|
|`OPENVPN_OPTS` | Will be passed to OpenVPN on startup | See [OpenVPN doc](https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html) |
|`LOCAL_NETWORK` | Sets the local network that should have access to the GUI | `LOCAL_NETWORK=192.168.0.0/24`|


#### User configuration options

By default OpenVPN will run as the root user and SABnzbd will run as user abc `1003:1003`. You may set the following parameters to customize the user id that runs SABnzbd.

| Variable | Function | Example |
|----------|----------|-------|
|`-e PUID` | Sets the user id who will run SABnzbd | `PUID=1003`|
|`-e PGID` | Sets the group id for the SABnzbd user | `PGID=1003` |


## Access the WebUI of SABnzbd

My http://my-host:8080 isn't responding?
This is because the VPN is active, and since docker is running in a different subnet than your client the response
to your request will be treated as "non-local" traffic and therefore be routed out through the VPN interface.

### How to fix this:
The container supports the `LOCAL_NETWORK` environment variable. For instance if your local network uses the IP range 192.168.0.0/24 you would pass `-e LOCAL_NETWORK=192.168.0.0/24`. 

Alternatively you can reverse proxy the traffic through another container, as that container would be in the docker range. 

```
$ docker run -d \
      --link <sabnzbdvpn-containername> \
      -p 8080:8080 \
      nginx:latest
```

## Tips and Tricks

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


### Using your ovpn config file

If you want to run the image with your own provider without building a new image, that is also possible. For some providers, like AirVPN, the .ovpn files are generated per user and contains credentials. They should not be added to a public image. This is what you do:

Add a new volume mount to your `docker run` command that mounts your config file:
`-v /path/to/your/config.ovpn:/etc/openvpn/custom/default.ovpn`

Note that you still need to modify your .ovpn file as described in the previous section. If you have an separate ca.crt file your volume mount should be a folder containing both the ca.crt and the .ovpn config.
