#!/bin/bash
# Copyright (c) 2018 KredsBlockchain.com
# kreds-auto.sh
# KREDS masternode installation for Ubuntu 16.04 and Ubuntu 18.04
# ATTENTION: The firewall part will disable all services like, http, https and dns ports.

#Warning this script will install all dependencies that you are need for this installation.
echo "WARNING: This script will download some dependencies and add an apt repo to your repository list."
printf "Press Ctrl+C to cancel or Enter to continue:" 
read IGNORE

echo "We will need to run as root to install dependencies. This script will run with 'sudo'"
printf "Press Cntrl+C to cancel or Enter to continue:"
read IGNORE

sudo apt install software-properties-common -y
sleep 10;
echo "starting downloading wallet dependencies...."
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sleep 10;
echo "update apt before we begin!"
sudo apt update
sudo apt install g++ pkg-config libssl-dev libevent-dev-y
sudo apt install curl libdb4.8-dev libdb4.8++-dev libboost-program-options-dev libboost-all-dev libevent-pthreads-2.0-5 libevent-2.0-5 autoconf -y


#if [[ $UID != 0 ]]; then
#    echo "Please run this script with sudo/or as a root user:"
#    echo "sudo $0 $*"
#    exit 1
#fi

while true; do
 if [ -d $user/.Frostbyte ]; then
   printf "$user/.Frostbyte/ already exists! The installer will delete this folder. Continue anyway?(Y/n)"
   read REPLY
   if [ ${REPLY} == "Y" ]; then
      pID=$(ps -ef | grep frostbyted | awk '{print $2}')
      kill ${pID}
      rm -rf $user/.frostbyte/
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


# Warning that the script will reboot your server once it's done with your Frostbyte Node!
echo "WARNING: This script will reboot the server once it's done with your Frostbyte Node!"
printf "Press Ctrl+C to cancel or Enter to continue: "
read IGNORE

cd
# Changing the SSH Port to a custom number is a good in a security measure against DDOS/botnet attacks
#printf "Custom SSH Port other than 22(Enter to ignore): "
#read VARIABLE
#_sshPortNumber=${VARIABLE:-22}

# Get a new privatekey by going to console >> debug and typing masternode genkey
printf "Obtain a new privatekey for your MasterNode by going to console - debug to get to the FrostByte console, then typing 'masternode genkey' and pushing ENTER."
printf "copy the key that was generated to paste into this SSH window"
printf "Enter Masternode PrivateKey: "

read _nodePrivateKey

# The RPC node will only accept connections from your localhost
printf "we will now create your RPC user and password automatically utilizing /dev/urandom"
_rpcUserName=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')

# Choose a random and secure password for the RPC
_rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

# Get your IP address of your vps which will be hosting the masternode
printf "if you know the IP address for your node, copy it and..."
printf "paste your IP address here:"

read _nodeIpAddress

#removed IP check due to various different setups for IP and firewall config, every VPS is not the same.
#_nodeIpAddress=`curl ipecho.net/plain`

echo _nodeIpAddress
# Make a new directory for Frostbyte wallet
rm -R $user/.frostbyte/
mkdir $user/.frostbyte/
touch $user/.frostbyte/frostbyte.conf

# Change the directory to $user/.frostbyte
cd $user/.frostbyte

# Create the initial frostbyte.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
daemon=1
port=22211
maxconnections=128
promode=1
masternode=1
externalip=${_nodeIpAddress}:22211
masternodeprivkey=${_nodePrivateKey}
" > frostbyte.conf
cd


echo "clone Frostbyte git... and compile daemon from source in new folder called 'BUILD'..."
sleep 5

mkdir BUILD
cd BUILD

printf "cloning frostbyte git..."
sleep 5

git clone https://github.com/Frostbytecoin/FSTX-Core.git
cd FSTX-Core

sleep 5
printf "making necessary executable files..."
sleep 5

chmod +x share/genbuild.sh
chmod +x autogen.sh
chmod +x src/leveldb/build_detect_platform

sleep 5
echo "running ./autogen.sh..."
sleep 5

./autogen.sh


printf "now running ./configure to prepare for wallet build..."
sleep 5

echo "running ./configure..."
./configure

sleep 10
printf "we will now build the frostbyte daemon and cli..."
sleep 5



make

sleep 5
printf "placing files in necessary user location for easy launch (/usr/bin)..."


cp src/frostbyted /usr/bin/
cp src/frostbyte-cli /usr/bin/



# Create a directory for FSTX-MN-AUTO's cronjobs...
echo "Adding all FSTX-MN-AUTO's scripts to crontab"
rm -R FSTX-MN-AUTO/fstx
mkdir -p FSTX-MN-AUTO/fstx

# Change the directory to ~/kreds-auto/
cd FSTX-MN-AUTO/fstx

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
# sed -i "s/[#]\{0,1\}[ ]\{0,1\}Port [0-9]\{2,\}/Port ${_sshPortNumber}/g" /etc/ssh/sshd_config

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
