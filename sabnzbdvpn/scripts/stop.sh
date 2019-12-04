#! /bin/sh

#. /etc/profile

#kill $(ps aux | grep sabnzbdplus | grep -v grep | awk '{print $2}')

tempPID="$(pgrep sabnzbdplus)"
kill ${tempPID}