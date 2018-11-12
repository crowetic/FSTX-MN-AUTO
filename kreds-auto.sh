#!/bin/bash
# Copyright (c) 2018 KredsBlockchain.com
# kreds-auto.sh
# KREDS masternode installation for Ubuntu 16.04 and Ubuntu 18.04
# ATTENTION: The firewall part will disable all services like, http, https and dns ports.

#Warning this script will install all dependencies that you are need for this installation.
echo "WARNING: This script will download some dependencies"
printf "Press Ctrl+C to cancel or Enter to continue:" 
read IGNORE


apt install software-properties-common -y
sleep 10;
echo "starting downloading KREDS dependencies...."
add-apt-repository ppa:bitcoin/bitcoin -y
sleep 10;
echo "update apt before we begin!"
apt update
apt install curl libdb4.8-dev libdb4.8++-dev libboost-program-options-dev libboost-all-dev libevent-pthreads-2.0-5 libevent-2.0-5 -y


if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo/or as a root user:"
    echo "sudo $0 $*"
    exit 1
fi

while true; do
 if [ -d ~/.kreds ]; then
   printf "~/.kreds/ already exists! The installer will delete this folder. Continue anyway?(Y/n)"
   read REPLY
   if [ ${REPLY} == "Y" ]; then
      pID=$(ps -ef | grep kredsd | awk '{print $2}')
      kill ${pID}
      rm -rf ~/.kreds/
      break
   else
      if [ ${REPLY} == "n" ]; then
        exit
      fi
   fi
 else
   break
 fi
done


# Warning that the script will reboot your server once it's done with your KREDS-NODE
echo "WARNING: This script will reboot the server once it's done with your KREDS node."
printf "Press Ctrl+C to cancel or Enter to continue: "
read IGNORE

cd
# Changing the SSH Port to a custom number is a good in a security measure against DDOS/botnet attacks
printf "Custom SSH Port other than 22(Enter to ignore): "
read VARIABLE
_sshPortNumber=${VARIABLE:-22}

# Get a new privatekey by going to console >> debug and typing masternode genkey
printf "Enter Masternode PrivateKey: "
read _nodePrivateKey

# The RPC node will only accept connections from your localhost
_rpcUserName=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')

# Choose a random and secure password for the RPC
_rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

# Get your IP address of your vps which will be hosting the masternode
_nodeIpAddress=`curl ipecho.net/plain`
echo _nodeIpAddress
# Make a new directory for KREDS daemon
rm -r ~/.kreds/
mkdir ~/.kreds/
touch ~/.kreds/kreds.conf

# Change the directory to ~/.kreds
cd ~/.kreds/

# Create the initial kreds.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
daemon=1
port=3950
maxconnections=64
promode=1
masternode=1
externalip=${_nodeIpAddress}:3950
masternodeprivkey=${_nodePrivateKey}
" > kreds.conf
cd

# Install dependencies for kredsd using apt-get
#apt-get install software-properties-common
#add-apt-repository ppa:kreds/ppa -y && apt update && apt install kredsd -y && kredsd

# Download kredsd and put executable files to /usr/bin

echo "Download kreds wallet from repository"
wget --no-check-certificate https://github.com/KredsBlockchain/kreds-core/releases/download/v1.0.0.6/kreds-linux64-v1.0.0.6.tar.xz

echo "unpack kreds tar.xz files"
tar -xvf ./kreds-linux64-v1.0.0.6.tar.xz
chmod +x ./kreds-linux64-v1.0.0.6/*

echo "Put all executable files to /usr/bin"
cp ./kreds-linux64-v1.0.0.6/kredsd /usr/bin/
cp ./kreds-linux64-v1.0.0.6/kreds-cli /usr/bin/

echo "remove all temp files!"
rm -r ./kreds-linux64-v1.0.0.6/
rm -r ./kreds-linux64-v1.0.0.6.tar.xz

# Create a directory for KREDS's cronjobs
echo "Adding all KREDS scripts to crontab"
rm -r kreds-auto/kreds
mkdir -p kreds-auto/kreds

# Change the directory to ~/kreds-auto/
cd ~/kreds-auto/kreds

# Download the appropriate scripts #edit
wget https://raw.githubusercontent.com/razerrazer/KREDS-AUTO/master/checkrun.sh
wget https://raw.githubusercontent.com/razerrazer/KREDS-AUTO/master/clearkredslog.sh
wget https://raw.githubusercontent.com/razerrazer/KREDS-AUTO/master/daemonchecker.sh

# Create a cronjob for making sure kredsd runs after reboot
if ! crontab -l | grep "@reboot kredsd"; then
  (crontab -l ; echo "@reboot kredsd") | crontab -
fi

# Create a cronjob for making sure kredsd is always running
if ! crontab -l | grep "~/kreds-auto/kreds/checkrun.sh"; then
  (crontab -l ; echo "*/5 * * * * ~/kreds-auto/kreds/checkrun.sh") | crontab -
fi

# Create a cronjob for making sure the daemon is never stuck
if ! crontab -l | grep "~/kreds-auto/kreds/daemonchecker.sh"; then
  (crontab -l ; echo "*/30 * * * * ~/kreds-auto/kreds/daemonchecker.sh") | crontab -
fi

# Create a cronjob for making sure kredsd is always up-to-date
#if ! crontab -l | grep "~/kreds-auto/kreds/upgrade.sh"; then
#  (crontab -l ; echo "0 0 */1 * * ~/kreds-auto/kreds/upgrade.sh") | crontab -
#fi

# Create a cronjob for clearing the log file
if ! crontab -l | grep "~/kreds-auto/kreds/clearkredslog.sh"; then
  (crontab -l ; echo "0 0 */2 * * ~/kreds-auto/kreds/clearkredslog.sh") | crontab -
fi

# Give execute permission to the cron scripts
chmod 0700 ./checkrun.sh
chmod 0700 ./daemonchecker.sh
chmod 0700 ./clearkredslog.sh

# Change the SSH port
sed -i "s/[#]\{0,1\}[ ]\{0,1\}Port [0-9]\{2,\}/Port ${_sshPortNumber}/g" /etc/ssh/sshd_config

# Firewall security measures
apt install ufw -y
ufw disable
ufw allow 3950
ufw allow "$_sshPortNumber"/tcp
ufw limit "$_sshPortNumber"/tcp
ufw logging on
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# Reboot the server after installation is done.
 read -r -p "reboot your server to compelete the installation? [Y/n]" response
 response=${response,,} # tolower
 if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    /sbin/reboot
 fi
