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
- The liveness probe needs an image with the reworked s6 scripts. Disable it for older images.

## Tuning

All settings go into `workload.main.podSpec` and `workload.main.podSpec.containers.main` in [values.yaml](values.yaml). See the [rclone-mount README](../../rclone-mount/README.md#environment-variables) for all environment variables.

**Shutdown time:** the image defaults finish the shutdown within about 8.5s, so `terminationGracePeriodSeconds: 10` is enough. If rclone needs longer to unmount (e.g. pending uploads with `--vfs-cache-mode writes`), raise `S6_KILL_FINISH_MAXTIME` and set the grace period about 3s above it. If the pod is killed before the unmount finishes, the mount stays behind on the node.

```yaml
workload:
  main:
    podSpec:
      terminationGracePeriodSeconds: 23
      containers:
        main:
          env:
            S6_KILL_FINISH_MAXTIME: "20000"   # ms, rclone gets this minus 2s to unmount itself
            S6_SERVICES_GRACETIME: "1000"     # ms, wait for the services after the unmount
            S6_KILL_GRACETIME: "1000"         # ms, between TERM and KILL for remaining processes
```

**Mount options:** all rclone mount flags go into `MountCommands`, e.g. `--vfs-cache-mode full --vfs-cache-max-size 50G` for a local cache or `--buffer-size 256M` for streaming. Put the cache on a volume (`--cache-dir /cache` with an extra `persistence` entry), otherwise it fills the node's container storage. See [rclone mount](https://rclone.org/commands/rclone_mount/).

**Logging:** set `RCLONE_LOG_LEVEL` in `env` to `DEBUG`, `INFO`, `NOTICE` (default) or `ERROR`.

**Start checks:** the pod stops when the rclone config is missing or a stale mount can't be removed (`S6_BEHAVIOUR_IF_STAGE2_FAILS: "2"`). Set it to `"0"` to start rclone anyway.

**Health check:** change `probes.liveness.spec` (`periodSeconds`, `failureThreshold`) to restart the pod faster or slower when the mount is dead, or set `probes.liveness.enabled: false` to turn it off.

**Resources:** rclone uses about `--buffer-size` of memory per open file, raise `resources.limits.memory` when many files are read at once.
