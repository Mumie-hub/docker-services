#! /bin/sh

. /scripts/userSetup.sh
exec sudo -u ${RUN_AS} /etc/init.d/sabnzbdplus stop &