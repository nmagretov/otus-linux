#!/bin/bash
#set -x
echo "------------------------------------------------------"
echo "Starting provisioning" `hostname` "from a scriptfile"
echo "------------------------------------------------------"

echo "creating local dns records"
echo "192.168.50.50    server" >> /etc/hosts
echo "192.168.50.51    client" >> /etc/hosts

echo "creating mount points and mounting"
mkdir /mnt/share
echo "server:/mnt/share/ /mnt/share/ nfs vers=3,proto=udp,hard,intr,rsize=32768,wsize=32768" >> /etc/fstab
echo "server:/mnt/share/upload /mnt/share/upload nfs vers=3,proto=udp,hard,intr,rsize=32768,wsize=32768" >> /etc/fstab
mount -a

echo "rebooting. just in case :)"
reboot