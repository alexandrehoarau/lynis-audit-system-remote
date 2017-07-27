#!/bin/bash
#Version : 2.0
#Usage : ./lynis-remote-audit.sh
#Description : Script to launch lynis audit to a remote server
#Author : Alexandre HOARAU

#Retrieve version and connection information


echo "Please enter lynis version, followed by [ENTER]:"
read version

echo "Please enter username, followed by [ENTER]:"
read -s username

echo "Please enter hostname, followed by [ENTER]:"
read -s hostname

echo "Path to Password File, followed by [ENTER]:"
read -s pass_file

#Create tarball to use on remote host

cp lynis-$version.tar.gz lynis-remote.tar.gz

#Copy TarBall to remote host by SCP

sshpass -f $pass_file scp lynis-remote.tar.gz $username@$hostname:~/tmp-lynis-remote.tgz

#Execute audit command

sshpass -f $pass_file ssh $username@$hostname "mkdir -p ~/tmp-lynis && cd ~/tmp-lynis && tar xzf ../tmp-lynis-remote.tgz && rm ../tmp-lynis-remote.tgz && cd lynis && ./lynis audit system"

##expect -c "
#   set timeout -1
#   spawn ssh $username@$hostname $audit_cmd
#   expect *assword:  { send $password\r ; exp_continue }
#   exit
#"

#Retrieve log and lynis reports

timestamp=$(date +%Y%m%d)

mkdir -p ~/lynis-logs/$hostname

##expect -c "  
#   set timeout 1
#   spawn scp $username@$hostname:/tmp/lynis.log ~/lynis-logs/$hostname/$timestamp-lynis.log
#   expect yes/no { send yes\r ; exp_continue }
#   expect *assword: { send $password\r }
#   expect 100%
#   sleep 1
#   exit
#"

sshpass -f $pass_file scp $username@$hostname:/tmp/lynis.log ~/lynis-logs/$hostname/$timestamp-lynis.log
#expect -c "  
#   set timeout 1
#   spawn scp $username@$hostname:/tmp/lynis-report.dat ~/lynis-logs/$hostname/$timestamp-lynis-report.dat
#   expect yes/no { send yes\r ; exp_continue }
#   expect *assword: { send $password\r }
#   expect 100%
#   sleep 1
#   exit
#"

sshpass -f $pass_file scp $username@$hostname:/tmp/lynis-report.dat ~/lynis-logs/$hostname/$timestamp-lynis-report.dat
#
##Remove temp directory
#expect -c "
#   set timeout -1
#   spawn ssh $username@$hostname rm -rf ~/tmp-lynis
#   expect *assword:  { send $password\r ; exp_continue }
#   exit
#"
#
sshpass -f $pass_file ssh $username@$hostname rm -rf ~/tmp-lynis

##Clean up tmp files (when using non-privileged account)
#
#expect -c "
#   set timeout -1
#   spawn ssh $username@$hostname rm /tmp/lynis.log /tmp/lynis-report.dat
#   expect *assword:  { send $password\r ; exp_continue }
#   exit
#"

sshpass -f $pass_file ssh $username@$hostname rm /tmp/lynis.log /tmp/lynis-report.dat
