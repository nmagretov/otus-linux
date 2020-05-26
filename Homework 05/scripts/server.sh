#!/bin/bash
#set -x
echo "------------------------------------------------------"
echo "Starting provisioning" `hostname` "from a scriptfile"
echo "------------------------------------------------------"

echo "creating local dns records"
echo "192.168.50.50    server" >> /etc/hosts
echo "192.168.50.51    client" >> /etc/hosts

echo "creating share folder and upload subfolder (for RW rights)"
mkdir -p /mnt/share/upload
chown -R nfsnobody:nfsnobody /mnt/share
chmod -R 777 /mnt/share

echo "creating mount points"
echo "/mnt/share/ 192.168.50.0/24(ro,no_root_squash,sync,wdelay,hide,crossmnt,no_all_squash,subtree_check)" >> /etc/exports
echo "/mnt/share/upload 192.168.50.0/24(rw,no_root_squash,sync,wdelay,hide,crossmnt,no_all_squash,subtree_check)" >> /etc/exports

echo "binding nfs port in /etc/sysconfig/nfs"
echo "RQUOTAD_PORT=875 " >> /etc/sysconfig/nfs
echo "LOCKD_TCPPORT=32803 " >> /etc/sysconfig/nfs
echo "LOCKD_UDPPORT=32769 " >> /etc/sysconfig/nfs
echo "MOUNTD_PORT=892 " >> /etc/sysconfig/nfs
echo "STATD_PORT=662 " >> /etc/sysconfig/nfs

echo "adding to autostart and starting nfs-server"
systemctl enable --now rpcbind nfs-lock nfs-server
systemctl restart rpcbind nfs nfs-server

# checking nfs-server capcabilities
# rpcinfo -p localhost

echo "setting up firewall interfaces, zones and ports"
systemctl start firewalld
firewall-cmd --zone=work --permanent --change-interface=eth1
#firewall-cmd --zone=work --permanent --add-service=nfs3 # didn`t work for me, so i had to set ports in a firewall manually from "rpcinfo -p localhost"
firewall-cmd --zone=work --add-port=111/tcp --permanent
firewall-cmd --zone=work --add-port=111/udp --permanent
firewall-cmd --zone=work --add-port=662/tcp --permanent
firewall-cmd --zone=work --add-port=662/udp --permanent
firewall-cmd --zone=work --add-port=892/tcp --permanent
firewall-cmd --zone=work --add-port=892/udp --permanent
firewall-cmd --zone=work --add-port=2049/tcp --permanent
firewall-cmd --zone=work --add-port=2049/udp --permanent
firewall-cmd --zone=work --add-port=32769/udp --permanent
firewall-cmd --zone=work --add-port=32803/tcp --permanent
firewall-cmd --reload
systemctl enable firewalld

echo "rebooting. just in case :)"
reboot