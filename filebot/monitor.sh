#!/bin/bash

CONFIG_FILE=$CONFIG_FILE
NAME=$(basename $CONFIG_FILE .conf)

#-----------------------------------------------------------------------------------------------------------------------

function ts {
  echo [`date '+%b %d %X'`] $NAME:
}

#-----------------------------------------------------------------------------------------------------------------------

function is_change_event {
  EVENT="$1"
  INFO="$2"

  # File events
  if [ "$EVENT" == "ATTRIB" ]
  then
    echo "$(ts) Detected file attribute change: $INFO"
  elif [ "$EVENT" == "CLOSE_WRITE,CLOSE" ]
  then
    EVENT=CLOSE_WRITE
    echo "$(ts) Detected new file: $INFO"
#  elif [ "$EVENT" == "MOVED_TO" ]
#  then
#    echo "$(ts) Detected file moved into dir: $INFO"
#  elif [ "$EVENT" == "MOVED_FROM" ]
#  then
#    echo "$(ts) Detected file moved out of dir: $INFO"
  elif [ "$EVENT" == "DELETE" ]
  then
    echo "$(ts) Detected deleted file: $INFO"

  # Directory events
  elif [ "$EVENT" == "ATTRIB,ISDIR" ]
  then
    echo "$(ts) Detected dir attribute change: $INFO"
#  elif [ "$EVENT" == "CREATE,ISDIR" ]
#  then
#    echo "$(ts) Detected new dir: $INFO"
#  elif [ "$EVENT" == "MOVED_TO,IS_DIR" ]
#  then
#    echo "$(ts) Detected dir moved into dir: $INFO"
#  elif [ "$EVENT" == "MOVED_FROM,IS_DIR" ]
#  then
#    echo "$(ts) Detected dir moved out of dir: $INFO"
  elif [ "$EVENT" == "DELETE,ISDIR" ]
  then
    echo "$(ts) Detected deleted dir: $INFO" 

  else
    return 1
  fi

  return 0
}

#-----------------------------------------------------------------------------------------------------------------------

function to_seconds {
  readarray elements < <(echo $1 | tr ':' '\n' | tac)

  SECONDS=0
  POWER=1

  for (( i=0 ; i<${#elements[@]}; i++ )) ; do
    SECONDS=$(( 10#$SECONDS + 10#${elements[i]} * 10#$POWER ))
    POWER=$(( 10#$POWER * 60 ))
  done

  echo "$SECONDS"
}

#-----------------------------------------------------------------------------------------------------------------------

function wait_for_events_to_stabilize {
  start_time=$(date +"%s")
  while true
  do
    if read -t $SETTLE_DURATION RECORD
    then
      end_time=$(date +"%s")

      if [ $(($end_time-$start_time)) -gt $MAX_WAIT_TIME ]
      then
        echo "$(ts) Input directory didn't stabilize after $MAX_WAIT_TIME seconds. Triggering command anyway."
        break
      fi
    else
      echo "$(ts) Input directory stabilized for $SETTLE_DURATION seconds. Triggering command."
      break
    fi
  done
}

#-----------------------------------------------------------------------------------------------------------------------

function wait_for_minimum_period {
  last_run_time=$1
  time_since_last_run=$(($(date +"%s")-$last_run_time))
  if [ $time_since_last_run -lt $MIN_PERIOD ]
  then
    remaining_time=$(($MIN_PERIOD-$time_since_last_run))

    echo "$(ts) Waiting an additional $remaining_time seconds before running command"
  fi

  # Process events while we wait for $MIN_PERIOD to expire
  while [ $time_since_last_run -lt $MIN_PERIOD ]
  do
    remaining_time=$(($MIN_PERIOD-$time_since_last_run))

    read -t $remaining_time RECORD

    time_since_last_run=$(($(date +"%s")-$last_run_time))
  done
}

#-----------------------------------------------------------------------------------------------------------------------

function wait_for_command_to_complete {
  PID=$1

  while ps -p $PID > /dev/null
  do
    sleep .1

    if [[ "$IGNORE_EVENTS" == "1" ]]
    then
      # -t 0 didn't work for me. Seemed to return success with no RECORD
      while read -t 0.001 RECORD; do :; done
    fi
  done
}

#-----------------------------------------------------------------------------------------------------------------------

echo "$(ts) Starting inotifywait monitor $CONFIG_FILE at $WATCH_DIR"

tr -d '\r' < $CONFIG_FILE > /tmp/$NAME.conf
. /tmp/$NAME.conf

SETTLE_DURATION=$(to_seconds $SETTLE_DURATION)
MAX_WAIT_TIME=$(to_seconds $MAX_WAIT_TIME)
MIN_PERIOD=$(to_seconds $MIN_PERIOD)
COMMAND="bash /config/filebot.sh" ###change to Monitor Config

pipe=$(mktemp -u)
mkfifo $pipe

inotifywait -r -m -q --format 'EVENT=%e WATCHED=%w FILE=%f' $WATCH_DIR >$pipe &

last_run_time=0

while true
do
  if read RECORD
  then
    #echo "$(ts) [DEBUG] $RECORD"

    EVENT=$(echo "$RECORD" | sed 's/EVENT=\([^ ]*\).*/\1/')
    INFO=$(echo "$RECORD" | sed 's/EVENT=[^ ]* //')

    if ! is_change_event "$EVENT" "$INFO"
    then
      continue
    fi

    # Monster up as many events as possible, until we hit the either the settle duration, or the max wait threshold.
    wait_for_events_to_stabilize

    # Wait until it's okay to run the command again, monstering up events as we do so
    wait_for_minimum_period $last_run_time

    echo "$(ts) Running command with user ID $USER_ID and group ID $GROUP_ID"
    #/sbin/setuser $USER_NAME $COMMAND &
    $COMMAND &
    PID=$!
    last_run_time=$(date +"%s")

    wait_for_command_to_complete $PID
  fi
done <$pipe