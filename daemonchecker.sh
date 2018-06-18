#!/bin/bash
# daemonchecker.sh
# Make sure the daemon is not stuck.
# Add the following to the crontab (i.e. crontab -e)
# */30 * * * * ~/kreds-auto/daemonchecker.sh

previousBlock=$(cat ~/kreds-auto/kreds/blockcount)
currentBlock=$(kreds-cli getblockcount)

kreds-cli getblockcount > ~/kreds-auto/blockcount

if [ "$previousBlock" == "$currentBlock" ]; then
  kreds-cli stop
  sleep 10
  kredsd
fi
