#!/bin/sh

mkdir -p $MountPoint
mkdir -p $ConfigDir

ConfigPath="$ConfigDir/$ConfigName"

echo "=================================================="
echo "Mounting $RemotePath to $MountPoint at: $(date +%Y.%m.%d-%T)"

#export EnvVariable

function term_handler {
  echo "sending SIGTERM to child pid"
  kill -SIGTERM ${!}      #kill last spawned background process $(pidof rclone)
  fuse_unmount
  echo "exiting container now"
  exit $?
}

function cache_handler {
  echo "sending SIGHUP to child pid"
  kill -SIGHUP ${!}
  wait ${!}
}

function fuse_unmount {
  echo "Unmounting: fusermount $UnmountCommands $MountPoint at: $(date +%Y.%m.%d-%T)"
  fusermount $UnmountCommands $MountPoint
}

#traps, SIGHUP is for cache clearing
trap term_handler SIGINT SIGTERM
trap cache_handler SIGHUP

#mount rclone remote and wait
/usr/sbin/rclone --config $ConfigPath --user-agent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36' mount $RemotePath $MountPoint $MountCommands &
wait ${!}
echo "rclone crashed at: $(date +%Y.%m.%d-%T)"
fuse_unmount

exit $?
