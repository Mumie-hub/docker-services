#!/bin/bash

# This script by default uses "Automated Media Center" (AMC). See the final filebot call below. For more docs on AMC,
# visit: http://www.filebot.net/forums/viewtopic.php?t=215

#-----------------------------------------------------------------------------------------------------------------------

# Specify the URLs of any scripts that you need. They will be downloaded into /config/scripts
SCRIPTS_TO_DOWNLOAD=(
# Example:
# https://raw.githubusercontent.com/filebot/scripts/devel/cleaner.groovy
)

#-----------------------------------------------------------------------------------------------------------------------

QUOTE_FIXER='replaceAll(/[\`\u00b4\u2018\u2019\u02bb]/, "'"'"'").replaceAll(/[\u201c\u201d]/, '"'"'""'"'"')'

# Customize the renaming format here. For info on formatting: https://www.filebot.net/naming.html

# Music/Eric Clapton/From the Cradle/05 - It Hurts Me Too.mp3
MUSIC_FORMAT="Music/{n.$QUOTE_FIXER}/{album.$QUOTE_FIXER}/{media.TrackPosition.pad(2)} - {t.$QUOTE_FIXER}"

# Movies/Fight Club.mkv
MOVIE_FORMAT="Filme/{n} {y}/{n.$QUOTE_FIXER} {y}.{vf}.{vc}.{' CD'+pi}"

# TV Shows/Game of Thrones/Season 05/Game of Thrones - S05E08 - Hardhome.mp4
# TV Shows/Game of Thrones/Special/Game of Thrones - S00E11 - A Day in the Life.mp4
SERIES_FORMAT="Serien/{n}/{episode.special ? 'Special' : 'Season '+s.pad(2)}/{n} - {episode.special ? 'S00E'+special.pad(2) : s00e00} - {t.${QUOTE_FIXER}.replaceAll(/[!?.]+$/).replacePart(', Part $1')}{'.'+lang}"

. $CONFIG_DIR/filebot.conf

if [ "$SUBTITLE_LANG" == "" ];then
  SUBTITLE_OPTION=""
else
  SUBTITLE_OPTION="subtitles=$SUBTITLE_LANG"
fi

#-----------------------------------------------------------------------------------------------------------------------

# Used to detect old versions of this script
VERSION=3

# Download scripts and such.
#. /files/pre-run.sh

# excludeList=$CONFIG_DIR/amc-exclude-list.txt
# See http://www.filebot.net/forums/viewtopic.php?t=215 for details on amc
filebot -script fn:amc -no-xattr --output $OUTPUT_DIR --log-file $CONFIG_DIR/amc.log --action move --conflict auto \
  -non-strict --def ut_dir=${WATCH_DIR} ut_kind=multi music=y skipExtract=y clean=y \
  $SUBTITLE_OPTION movieFormat="$MOVIE_FORMAT" musicFormat="$MUSIC_FORMAT" seriesFormat="$SERIES_FORMAT"
