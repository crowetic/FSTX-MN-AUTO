# KREDS-AUTO MASTERNODE INSTALLER!
### Bash installer for kreds masternode on the latest stable Ubuntu LTS version.

#### This shell script comes with 3 cronjobs: 
1. Make sure the daemon is always running: `checkrun.sh`
2. Make sure the daemon is never stuck: `daemonchecker.sh`
3. Clear the log file every other day to keep your machine alive : `clearkredslog.sh`

#### Login to your vps as root, download the install.sh file and then run it:
```
wget https://raw.githubusercontent.com/razerrazer/KREDS-AUTO/master/kreds-auto.sh
bash ./kreds-auto.sh
```

#### On the client-side, add the following line to masternode.conf:
```
node-alias xxxVPS-IPxxx:3950 node-key collateral-txid vout 0 or 1 at the end
```

#### Run the qt wallet, go to MASTERNODE tab, click "Start Missing" at the bottom (before unlock your addresses under inputs.)

#### BECAUSE YOUR THOUGHTS HAVE VALUE! https://www.kredsblockchain.com/
