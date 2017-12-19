#!/usr/bin/expect -f
# Set variables
 set username [lindex $argv 0]
 set password [lindex $argv 1]
 set enablepassword [lindex $argv 1]
 set VLANID [lindex $argv 2]
 set IP [lindex $argv 3]
 set NETMASK [lindex $argv 4]
 set NETWORK [lindex $argv 5]
 set WILDCARD [lindex $argv 6]
 set description [lindex $argv 7]
 set hostname "192.168.63.1"
# Log results
 log_file -a ~/results.log
 
# Announce which device we are working on and at what time
 send_user "\n"
 send_user ">>>>>  Working on $hostname @ [exec date] <<<<<\n"
 send_user "\n"
 
# Don't check keys
 spawn ssh -o StrictHostKeyChecking=no $username\@$hostname
 
# Allow this script to handle ssh connection issues
 expect {
 timeout { send_user "\nTimeout Exceeded - Check Host\n"; exit 1 }
 eof { send_user "\nSSH Connection To $hostname Failed\n"; exit 1 }
 "*#" {}
 "*assword:" {
 send "$password\n"
 }
 }
 
# If we're not already in enable mode, get us there
 expect {
 default { send_user "\nEnable Mode Failed - Check Password\n"; exit 1 }
 "*#" {}
 "*>" {
 send "enable\n"
 expect "*assword"
 send "$enablepassword\n"
 expect "*#"
 }
 }
 
 
 
 
# Let's go to configure mode
 send "conf t\n"
 expect "(config)#"
 
 send "interface GigabitEthernet0/1.$VLANID\n"
 expect "(config-subif)#"
 send "description $description\n"
 expect "(config-subif)#"
  send "encapsulation dot1Q $VLANID\n"
 expect "(config-subif)#"
   send "ip nat inside\n"
 expect "(config-subif)#"
   send "ip virtual-reassembly in\n"
 expect "(config-subif)#"
 send "ip address $IP $NETMASK\n"
 expect "(config-subif)#"
 send "access-list 105 permit ip $NETWORK $WILDCARD any\n"
 expect "(config)#"

  send "ip dhcp pool $VLANID\n"
 expect "(dhcp-config)#"
 send "network $NETWORK $NETMASK\n"
 expect "(dhcp-config)#"
 send "dns-server 8.8.8.8 8.8.4.4\n"
 expect "(dhcp-config)#"
 send "default-router $IP\n"
 
 send "end\n"
 expect "#"
 send "write mem\n"
 expect "#"
 send "exit\n"
 expect ":~\$"
 exit