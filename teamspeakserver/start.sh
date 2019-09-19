#!/bin/sh

case $TS_VERSION in
  LATEST)
    export TS_VERSION=`/get-version.py`
    ;;
esac
#echo "$TS_VERSION" handle Update here!
echo "$TS_VERSION" > /teamspeak/ts-version.docker

cd $DATA_DIR

TARFILE=teamspeak3-server_linux_amd64-$TS_VERSION.tar.bz2

if [ ! -e ${TARFILE} ]; then
  echo "Downloading $TARFILE ..."
  wget -q http://dl.4players.de/ts/releases/$TS_VERSION/$TARFILE #\
  ##&& tar -j -x -f $TARFILE
fi

export LD_LIBRARY_PATH=/teamspeak

#if [ -e /$DATA_DIR/ts3server.ini ]; then
#  TS3ARGS="inifile=/$DATA_DIR/ts3server.ini"
#else
#  TS3ARGS="createinifile=1"
#fi

exec $DATA_DIR/ts3server $TS3ARGS