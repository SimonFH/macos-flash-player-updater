#!/bin/sh
# Run to install daemon in ~/Library/LaunchAgents/
# Provide an optional argument of the interval of the daemon, in seconds.
# For example 
#   ./install.sh 7200
# to run every 2 hours.
# Default interval is 3600 seconds (1 hour).
# To remove, run 
#   ./install.sh uninstall

DAEMON=~/Library/LaunchAgents/local.updateflash.plist

if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
 SECONDS="$1" 
else
 SECONDS=3600
fi

if [ "$1" = "uninstall" ]; then
  launchctl stop $DAEMON
  launchctl unload $DAEMON
  rm $DAEMON
  exit 0
fi

touch $DAEMON
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cat ./template.plist|awk -v sloc="$DIR/updflsh.sh" -v seconds="$SECONDS" '{gsub("SCRIPT_LOCATION", sloc);gsub("INTERVAL_SECONDS", seconds); print $0}'>$DAEMON

launchctl load $DAEMON
launchctl start $DAEMON
