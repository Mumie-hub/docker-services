# rclone-mount on Kubernetes

Example [values.yaml](values.yaml) to run the [rclone-mount](../../rclone-mount/) image with the TrueCharts [app-template](https://truecharts.org/charts/stable/app-template) chart.

```sh
helm install rclone oci://oci.trueforge.org/truecharts/app-template --version 18.23.5 \
  --namespace rclone --create-namespace -f values.yaml
```

Copy your rclone config to `/config/.rclone.conf` in the config PVC, rclone can't mount without it.

## How the mount works

- The pod runs privileged, FUSE and `Bidirectional` mount propagation need it.
- The host folder `/mnt` is mounted into the pod at the same path and rclone mounts at `MountPoint` below it (`/mnt/mediaefs`), so the node sees the mount at the same path.
- Mount the parent folder, not the mount point itself. If a pod is killed, a dead mount stays on the node. With the parent folder mounted, the next pod removes it on start. Otherwise run `fusermount -uz /mnt/mediaefs` on the node.
- Pin the pod to a node with a `nodeSelector`. Pods using the mount (Plex etc.) need to run on the same node and mount the folder with `mountPropagation: HostToContainer`, otherwise they don't see the mount after rclone restarts.
- rclone gets `S6_KILL_FINISH_MAXTIME` (20s) to unmount on shutdown, keep `terminationGracePeriodSeconds` 10s above it.
- The liveness probe needs an image with the reworked s6 scripts. Disable it for older images.
