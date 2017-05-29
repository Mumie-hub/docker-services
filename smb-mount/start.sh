#!/bin/sh

echo "============================================="
echo "Mounting SMB from $SERVERPATH to $MOUNTPOINT at $(date +%Y.%m.%d-%T)"

#export EnvVariable

function term_handler {
  kill -SIGTERM ${!} #kill last spawned background process
  echo "sending SIGTERM to child pid"
  unmount
  echo "exiting now"
  exit $?
}

function unmount {
  echo "Unmounting: fusermount -u $MOUNTPOINT $(date +%Y.%m.%d-%T)"
  umount $MOUNTPOINT
}

trap term_handler SIGHUP SIGINT SIGTERM

while true
do
  mount.cifs -o username=$USERNAME,password=$PASSWORD $SERVERPATH $MOUNTPOINT $MountCommands & wait ${!}
  echo "smb mount crashed"
  unmount
done

exit 144