#!/bin/sh

mkdir -p $MountPoint
mkdir -p $ConfigDir

ConfigPath="$ConfigDir/$ConfigName"

echo "============================================="
echo "Mounting $RemotePath to $MountPoint at $(date +%Y.%m.%d-%T)"

#export EnvVariable

function term_handler {
  kill -SIGTERM ${!} #kill last spawned background process
  echo "sending SIGTERM to child pid"
#  kill -SIGTERM "$pid_rclone"
#  wait "$pid_rclone"
  fuse_unmount
  echo "exiting now"
#  kill $(jobs -p)
  exit $?
}

function fuse_unmount {
  echo "Unmounting: fusermount -u $MountPoint $(date +%Y.%m.%d-%T)"
  fusermount -u -z $MountPoint
}

# SIGHUP is for cache clearing
trap term_handler SIGINT SIGTERM

while true
do
  /usr/sbin/rclone --config $ConfigPath mount $RemotePath $MountPoint $MountCommands & wait ${!}
  echo "rclone crashed at: $(date +%Y.%m.%d-%T)"
#  tail -f /dev/null & wait ${!}
  fuse_unmount
#  sleep 1
done

exit 144