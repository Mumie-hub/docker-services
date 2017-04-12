#!/bin/bash

#CONFIG_FILE=$1

function ts {
  echo [`date '+%b %d %X'`]
}

#----------------------------------------------------------------

function check_config {
  if [[ ! -d "$WATCH_DIR" ]]; then
    echo "$(ts) WATCH_DIR specified in $CONFIG_FILE must be a directory."
    exit 1
  fi

  if [[ ! "$SETTLE_DURATION" =~ ^([0-9]{1,2}:){0,2}[0-9]{1,2}$ ]]; then
    echo "$(ts) SETTLE_DURATION must be defined in $CONFIG_FILE as HH:MM:SS or MM:SS or SS."
    exit 1
  fi

  if [[ ! "$MAX_WAIT_TIME" =~ ^([0-9]{1,2}:){0,2}[0-9]{1,2}$ ]]; then
    echo "$(ts) MAX_WAIT_TIME must be defined in $CONFIG_FILE as HH:MM:SS or MM:SS or SS."
    exit 1
  fi

  if [[ ! "$MIN_PERIOD" =~ ^([0-9]{1,2}:){0,2}[0-9]{1,2}$ ]]; then
    echo "$(ts) MIN_PERIOD must be defined in $CONFIG_FILE as HH:MM:SS or MM:SS or SS."
    exit 1
  fi

  if [[ ! "$USER_ID" =~ ^[0-9]{1,}$ ]]; then
    echo "$(ts) USER_ID must be defined in $CONFIG_FILE as a whole number."
    exit 1
  fi

  if [[ ! "$GROUP_ID" =~ ^[0-9]{1,}$ ]]; then
    echo "$(ts) GROUP_ID must be defined in $CONFIG_FILE as a whole number."
    exit 1
  fi
  echo "$(ts) $CONFIG_FILE Config checked"
}

#-----------------------------------------------------------------------------------------

#tr -d '\r' < $CONFIG_FILE > /tmp/$NAME.conf

. $CONFIG_DIR/filebot.conf

check_config

#SETTLE_DURATION=$(to_seconds $SETTLE_DURATION)
#MAX_WAIT_TIME=$(to_seconds $MAX_WAIT_TIME)
#MIN_PERIOD=$(to_seconds $MIN_PERIOD)

echo "$(ts) CONFIGURATION ---------------:"
echo "$(ts)       WATCH_DIR=$WATCH_DIR"
echo "$(ts) SETTLE_DURATION=$SETTLE_DURATION"
echo "$(ts)   MAX_WAIT_TIME=$MAX_WAIT_TIME"
echo "$(ts)      MIN_PERIOD=$MIN_PERIOD"
echo "$(ts)         USER_ID=$USER_ID"
echo "$(ts)        GROUP_ID=$GROUP_ID"
echo "$(ts)           UMASK=$UMASK"
echo "$(ts)           DEBUG=$DEBUG"
echo "$(ts)   IGNORE_EVENTS=$IGNORE_EVENTS"