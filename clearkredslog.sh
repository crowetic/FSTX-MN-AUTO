#!/bin/bash
# clearkredslog.sh
# Clear debug.log every other day
# Add the following to the crontab (i.e. crontab -e)
# 0 0 */2 * * ~/kreds-auto/kreds/clearkredslog.sh

/bin/date > ~/.kreds/debug.log
