#!/bin/bash

# Step 1 = Determines the OS Distribution
# Step 2 = Determines the OS Version ID
# Step 3 = Downloads Zabbix-Agent Repository & Installs the Zabbix-Agent
# Step 4 = Update Zabbix-Agent Config, Enable Service to auto start post Boot & Restart Zabbix-Agent
# Step 5 = Installation Completion Greeting

function editzabbixconf()
{
echo ========================================================================
echo Step 3 = Downloading Zabbix Repository and Installing Zabbix-Agent	
echo !! 3 !! Zabbix-Agent Installed
echo ========================================================================

mv /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.original
cp /etc/zabbix/zabbix_agentd.conf.original /etc/zabbix/zabbix_agentd.conf	
sed -i "s+Server=127.0.0.1+Server=MG-EC-UT-US-VM-ZABBIX-0001.xenetix.systems,MG-EC-UT-US-VM-ZABBIX-0002.xenetix.systems+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+ServerActive=127.0.0.1+ServerActive=MG-EC-UT-US-VM-ZABBIX-0001.xenetix.systems,MG-EC-UT-US-VM-ZABBIX-0002.xenetix.systems+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+Hostname=Zabbix server+Hostname=$(hostname -f)+g" /etc/zabbix/zabbix_agentd.conf
sed -i "s+# Timeout=3+Timeout=30+g" /etc/zabbix/zabbix_agentd.conf

echo ========================================================================
echo Step 4 = Working on Zabbix-Agent Configuration
echo !! 4 !! Updated Zabbix-Agent conf file at /etc/zabbix/zabbix_agentd.conf
echo !! 4 !! Enabled Zabbix-Agent Service to Auto Start at Boot Time
echo !! 4 !! Restarted Zabbix-Agent post updating conf file
echo ========================================================================
}


function ifexitiszero()
{
if [[ $? == 0 ]];
then editzabbixconf
else echo :-/ Failed at Step 3 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0

fi
}

function ubuntu22()
{
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu22.04_all.deb
dpkg -i zabbix-release_latest_7.0+ubuntu22.04_all.deb
apt update
apt install zabbix-agent -y
ifexitiszero
systemctl enable zabbix-agent
systemctl restart zabbix-agent
}


#VERSION ID FUNCTION'S LISTED BELOW

function version_id_ubuntu()
{
u1=$(cat /etc/*release* | grep VERSION_ID=)
echo !! 2 !! OS Version determined as $u1  #prints os version id like this : VERSION_ID="8.4"

u2=$(echo $u1 | cut -c13- | rev | cut -c2- |rev)
#echo $u2        #prints os version id like this : 8.4

u3=$(echo $u2 | awk '{print int($1)}')
#echo $u3       #prints os version id like this : 8
if [[ $u3 -eq 22 ]];      then ubuntu22
else echo :-/ Failed at Step 2 : We"'"re Sorry. This script cannot be used for zabbix-agent installation on this machine && exit 0
fi
}

#STEP 1 - SCRIPT RUNS FROM BELOW


echo Starting Zabbix-Agent Installation Script
echo ========================================================================

#STEP 5
echo ========================================================================
echo Congrats. Zabbix-Agent Installion is completed successfully.
echo Zabbix-Agent is installed, started and enabled to be up post reboot on this machine.
echo You can now add the host $(hostname -f) with IP $(hostname -i) on the Zabbix-Server Front End.
echo ========================================================================
echo To check zabbix-agent service status, you may run : service zabbix-agent status
echo To check zabbix-agent config, you may run : egrep -v '"^#|^$"' /etc/zabbix/zabbix_agentd.conf
echo To check zabbix-agent logs, you may run : tail -f /var/log/zabbix/zabbix_agentd.log
echo ========================================================================