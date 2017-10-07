# SABnzbd and OpenVPN
Docker container which runs SABnzbd while connecting to OpenVPN.

## Run container from Docker registry
The container is available from the Docker registry and this is the simplest way to get it.
To run the container use this command:

```
$ docker run -d --name CONTAINER_NAME \
              -v /your/storage/path/:/data \
              -v /etc/localtime:/etc/localtime:ro \
              -e "OPENVPN_PROVIDER=CUSTOM" \
              -e "OPENVPN_CONFIG=Netherlands" \
              -e "OPENVPN_USERNAME=user" \
              -e "OPENVPN_PASSWORD=pass" \
              -p 8080:8080 \
              mumie/sabnzbdvpn
```

You must set the environment variables `OPENVPN_PROVIDER`, `OPENVPN_USERNAME` and `OPENVPN_PASSWORD` to provide basic connection details.

The `OPENVPN_CONFIG` is an optional variable. If no config is given, a default config will be selected for the provider you have chosen.
Find available OpenVPN configurations by looking in the openvpn folder of the GitHub repository.

As you can see, the container also expects a data volume to be mounted.
This is where Transmission will store your downloads, incomplete downloads and look for a watch directory for new .torrent files.
By default a folder named transmission-home will also be created under /data, this is where Transmission stores its state.


### Required environment options
| Variable | Function | Example |
|----------|----------|-------|
|`OPENVPN_PROVIDER` | Sets the OpenVPN provider to use. | `OPENVPN_PROVIDER=provider`. Supported providers and their config values are listed in the table above. |
|`OPENVPN_USERNAME`|Your OpenVPN username |`OPENVPN_USERNAME=asdf`|
|`OPENVPN_PASSWORD`|Your OpenVPN password |`OPENVPN_PASSWORD=asdf`|

### Network configuration options
| Variable | Function | Example |
|----------|----------|-------|
|`OPENVPN_CONFIG` | Sets the OpenVPN endpoint to connect to. | `OPENVPN_CONFIG=UK Southampton`|
|`OPENVPN_OPTS` | Will be passed to OpenVPN on startup | See [OpenVPN doc](https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html) |
|`LOCAL_NETWORK` | Sets the local network that should have access. | `LOCAL_NETWORK=192.168.0.0/24`|

### Transmission configuration options

You may override transmission options by setting the appropriate environment variable.

The environment variables are the same name as used in the transmission settings.json file
and follow the format given in these examples:


PS: `TRANSMISSION_BIND_ADDRESS_IPV4` will be overridden to the IP assigned to your OpenVPN tunnel interface.
This is to prevent leaking the host IP.

### User configuration options

By default everything will run as the root user. However, it is possible to change who runs the transmission process. 
You may set the following parameters to customize the user id that runs transmission.

| Variable | Function | Example |
|----------|----------|-------|
|`PUID` | Sets the user id who will run transmission | `PUID=1003`|
|`PGID` | Sets the group id for the transmission user | `PGID=1003` |


## Access the WebUI
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

## Known issues, tips and tricks

#### Use Google DNS servers
Some have encountered problems with DNS resolving inside the docker container.
This causes trouble because OpenVPN will not be able to resolve the host to connect to.
If you have this problem use dockers --dns flag to override the resolv.conf of the container.
For example use googles dns servers by adding --dns 8.8.8.8 --dns 8.8.4.4 as parameters to the usual run command.

#### Restart container if connection is lost
If the VPN connection fails or the container for any other reason loses connectivity, you want it to recover from it. One way of doing this is to set environment variable `OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60` and use the --restart=always flag when starting the container. This way OpenVPN will exit if ping fails over a period of time which will stop the container and then the Docker deamon will restart it.

### Using a custom provider

If you want to run the image with your own provider without building a new image, that is also possible. For some providers, like AirVPN, the .ovpn files are generated per user and contains credentials. They should not be added to a public image. This is what you do:

Add a new volume mount to your `docker run` command that mounts your config file:
`-v /path/to/your/config.ovpn:/etc/openvpn/custom/default.ovpn`

Then you can set `OPENVPN_PROVIDER=CUSTOM`and the container will use the config you provided. If you are using AirVPN or other provider with credentials in the config file, you still need to set `OPENVPN_USERNAME` and `OPENVPN_PASSWORD` as this is required by the startup script. They will not be read by the .ovpn file, so you can set them to whatever.

Note that you still need to modify your .ovpn file as described in the previous section. If you have an separate ca.crt file your volume mount should be a folder containing both the ca.crt and the .ovpn config.
