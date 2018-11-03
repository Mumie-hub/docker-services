#!/bin/sh

echo "============================================="
echo "Mounting SMB $SERVERPATH to $MOUNTPOINT at $(date +%Y.%m.%d-%T)"

#export EnvVariable

function term_handler {
  unmount_smb
  echo "exiting container now"
  exit 0
}

function unmount_smb {
  echo "Unmounting: $MOUNTPOINT $(date +%Y.%m.%d-%T)"
  umount $UMOUNTOPTIONS $MOUNTPOINT
  wait ${!}
  sleep 1
}

trap term_handler SIGHUP SIGINT SIGTERM

mount -t cifs -o $MOUNTOPTIONS $SERVERPATH $MOUNTPOINT

while true
do
  if grep -qs "$MOUNTPOINT" /proc/mounts; then
    sleep 120
    #echo "sleep"
  else
    echo "Error mounting $SERVERPATH $(date +%Y.%m.%d-%T)"
    sleep 5
    exit 144
  fi
done

exit 145