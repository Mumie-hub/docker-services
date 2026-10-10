# docker-services

Container images for self-hosted services, most of them based on alpine to stay lightweight.
All services are built for a graceful shutdown/restart with S6 overlay or a small init script.

## Services

| Service                               | Description                                                                                   | Image                                                       |
| ------------------------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| [rclone-mount](rclone-mount/)         | Mount any rclone remote (Google Drive, S3, crypt, ...) with FUSE and share it with the host and other containers | `mumiehub/rclone-mount`, `ghcr.io/mumie-hub/rclone-mount` |
| [smb-mount](smb-mount/)               | Mount an SMB/CIFS share and share it with the host and other containers                       | `mumiehub/smb-mount`                                        |
| [sabnzbdvpn](sabnzbdvpn/)             | SABnzbd running behind an OpenVPN connection                                                  | `mumiehub/sabnzbdvpn`                                       |
| [jdownloader](jdownloader/)           | Headless JDownloader 2, not published since 2021                                              | `mumiehub/jdownloader`                                      |
| [filebot](filebot/)                   | FileBot watch folder renaming, not built anymore                                              | `mumiehub/filebot`                                          |
| [teamspeakserver](teamspeakserver/)   | **Deprecated**, see below                                                                     | `mumiehub/teamspeakserver`                                  |

### TeamSpeak

The teamspeakserver image is deprecated and not maintained anymore. Use the official images instead:

- TeamSpeak 3: [`teamspeak`](https://hub.docker.com/_/teamspeak) (Docker Official Image)
- TeamSpeak 6: [`teamspeaksystems/teamspeak6-server`](https://hub.docker.com/r/teamspeaksystems/teamspeak6-server)

## Usage

See the README in each service folder for the required `docker run` options, volumes and environment variables. Mount containers like rclone-mount and smb-mount need `--cap-add SYS_ADMIN`, `--security-opt apparmor=unconfined` and a `:shared` volume so the mount is visible on the host.

For Kubernetes there is an example for rclone-mount with the TrueCharts app-template Helm chart in [helm/rclone-mount](helm/rclone-mount/).

## Build and release

The repository lives on GitLab and is mirrored to [GitHub](https://github.com/Mumie-hub/docker-services).

- **GitLab CI** builds the images with Kaniko on a Kubernetes runner when files in a service folder change:
  - `dev` branch: `<service>:dev`, `<service>:dev-<version>` and `<service>:dev-<commit>` in the GitLab registry
  - `master` branch: `<service>:<version>-<commit>`, `<service>:<version>`, `<service>:<major.minor>` and `<service>:latest` in the GitLab registry, then a manual job copies them to Docker Hub (`mumiehub/<service>`)
- **GitHub Actions** builds rclone-mount for amd64 and arm64 and publishes it to GHCR (`ghcr.io/mumie-hub/rclone-mount`) with the same tags. A weekly workflow deletes old `dev-<commit>` builds and untagged images from GHCR.
- **Renovate** opens merge requests into `dev` when a new upstream version is released (e.g. rclone), configured in `renovate.json`.

The version of the upstream software is set in `<service>/version` (e.g. `rclone-mount/version`). It is passed to the build as `IMAGE_VERSION` and used as image tag. The `<version>-<commit>` tag never changes, the other tags move to the newest build. Services without a version file are tagged `<commit>` and `latest`.

Changes go to the `dev` branch first and are merged into `master` with a merge request.
