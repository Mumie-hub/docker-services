#! /bin/sh

#. /etc/profile

#exec sudo -u ${USER_NAME} /etc/init.d/sabnzbdplus stop &
kill $(ps aux | grep sabnzbdplus | grep -v grep | awk '{print $2}')