#!/bin/sh

mountCheck=`mount | grep -c $MOUNTPOINT`

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
  #sleep 1
}

trap term_handler SIGHUP SIGINT SIGTERM

mount -t cifs -o $MOUNTOPTIONS $SERVERPATH $MOUNTPOINT

if [ $mountCheck -eq 0 ] ; then
  echo "Error mounting $SERVERPATH $(date +%Y.%m.%d-%T)"
  exit 146
fi

while true
do
  sleep 100
done