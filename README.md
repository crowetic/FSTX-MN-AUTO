# FrostByte Coin AUTO MASTERNODE INSTALLER!
## Bash installer for FSTX masternode on the latest stable Ubuntu 16.04 LTS version.

### This shell script comes with 3 cronjobs: 
1. Make sure the daemon is always running: `checkrun.sh`
2. Make sure the daemon is never stuck: `daemonchecker.sh`
3. Clear the log file every other day to keep your machine alive : `clearfstxlog.sh`

### Login to your vps as root, download the install.sh file and then run it:
```
wget https://raw.githubusercontent.com/razerrazer/KREDS-AUTO/master/kreds-auto.sh
bash ./kreds-auto.sh
```

### On the client-side, add the following line to masternode.conf:
#### things in (parenthesis) are to be edited, and parenthesis themselves not to be included. 
#### gives you the format/structure for the information and which information to provide only. Do not copy/paste this info without modification or it will not work. 
#### Information with _ means there CANNOT BE A SPACE. SPACES ARE READ BY THE SOFTWARE AND ARE ONLY PLACED WHEN NECESSARY!

```
(node_alias) (hosted-VM-IP:port) (masternode_private_key) (collateral_txid) (vout) 

```
*****note - 'vout' is the '0' or '1' at the end of the txid***

#### Run the qt wallet, go to MASTERNODE tab, click "Start Missing".


##### **Thanks to the KREDS team for the original script! Modifications here done by crowetic.
