#!/bin/sh

echo "============================================="
echo "Mounting SMB from $SERVERPATH to $MOUNTPOINT at $(date +%Y.%m.%d-%T)"

#export EnvVariable

function term_handler {
  unmount
  echo "exiting now"
  exit 0
}

function unmount {
  echo "Unmounting: $MOUNTPOINT $(date +%Y.%m.%d-%T)"
  umount $MOUNTPOINT
}

trap term_handler SIGHUP SIGINT SIGTERM

mount.cifs -o username=$USERNAME,password=$PASSWORD $SERVERPATH $MOUNTPOINT $MountCommands

while true
do
sleep 10
done

exit 144