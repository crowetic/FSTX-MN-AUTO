#!/bin/bash
# checkrun.sh
# Make sure kreds is always running.
# Add the following to the crontab (i.e. crontab -e)
# */5 * * * * ~/kreds-auto/checkrun.sh

if ps -A | grep kredsd > /dev/null
then
  exit
else
  kredsd &
fi
