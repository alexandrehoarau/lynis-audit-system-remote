#!/bin/bash

#Script to lauch lynis audit to a remote server

#Retrieve version and connection information

version=$1
username=$2
hostname=$3
password=$4


if [ $# -eq 0 ]; then
    echo -e "ERROR : No Arguments Provided\n Usage: ./lynis-remote-host <lynis-version> <username> <hostname> <password>"
    exit 1
fi
if [ $# -lt 4 ]; then
    echo -e "ERROR : Missing Arguments\n Usage: ./lynis-remote-host <lynis-version> <username> <hostname> <password>"
    exit 1
fi

if [ $# -gt 4 ]; then
    echo -e "ERROR : Too much Arguments\n Usage: ./lynis-remote-host <lynis-version> <username> <hostname> <password>"
    exit 1
fi

#Create tarball to use on remote host
cp lynis-$version.tar.gz lynis-remote.tar.gz

#Copy TarBall to remote host by SCP

expect -c "  
   set timeout 1
   spawn scp lynis-remote.tar.gz $username@$hostname:~/tmp-lynis-remote.tgz
   expect yes/no { send yes\r ; exp_continue }
   expect *assword: { send $password\r }
   expect 100%
   sleep 1
   exit
" 

#Execute audit command

audit_cmd="mkdir -p ~/tmp-lynis && cd ~/tmp-lynis && tar xzf ../tmp-lynis-remote.tgz && rm ../tmp-lynis-remote.tgz && cd lynis && ./lynis audit system "

expect -c "
   set timeout -1
   spawn ssh $username@$hostname $audit_cmd
   expect *assword:  { send $password\r ; exp_continue }
   exit
"

#Retrieve log and lynis reports

timestamp=$(date +%Y%m%d)

mkdir -p ~/lynis-logs/$hostname

expect -c "  
   set timeout 1
   spawn scp $username@$hostname:/tmp/lynis.log ~/lynis-logs/$hostname/$timestamp-lynis.log
   expect yes/no { send yes\r ; exp_continue }
   expect *assword: { send $password\r }
   expect 100%
   sleep 1
   exit
"


expect -c "  
   set timeout 1
   spawn scp $username@$hostname:/tmp/lynis-report.dat ~/lynis-logs/$hostname/$timestamp-lynis-report.dat
   expect yes/no { send yes\r ; exp_continue }
   expect *assword: { send $password\r }
   expect 100%
   sleep 1
   exit
"

#Remove temp directory
expect -c "
   set timeout -1
   spawn ssh $username@$hostname rm -rf ~/tmp-lynis
   expect *assword:  { send $password\r ; exp_continue }
   exit
"

#Clean up tmp files (when using non-privileged account)

expect -c "
   set timeout -1
   spawn ssh $username@$hostname rm /tmp/lynis.log /tmp/lynis-report.dat
   expect *assword:  { send $password\r ; exp_continue }
   exit
"
