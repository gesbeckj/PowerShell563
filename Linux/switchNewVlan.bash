#!/usr/bin/expect -f
# Set variables
 set username [lindex $argv 0]
 set password [lindex $argv 1]
 set enablepassword [lindex $argv 1]
 set VLANID [lindex $argv 2]
 set name [lindex $argv 3]
 set hostname "192.168.63.2"
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
 
 send "vlan $VLANID\n"
 expect "(config-vlan)#"
 send "name $name\n"
  expect "(config-vlan)#"
 
 
 send "end\n"
 expect "#"
 send "write mem\n"
 expect "#"
 send "exit\n"
 expect ":~\$"
 exit