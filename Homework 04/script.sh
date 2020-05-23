#!/bin/bash
set -x
# installing zfs in Centos 8
yum install -y yum-utils
yum install -y http://download.zfsonlinux.org/epel/zfs-release.el8_0.noarch.rpm
gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
yum-config-manager --enable zfs-kmod
yum-config-manager --disable zfs
yum install -y zfs

# adding 5 zfs disks with different compression type/level
/sbin/modprobe zfs
zpool create compression /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf
mkdir -p /data/{gzip,gzip-9,lz4,lzjb,zle}
zfs create compression/gzip
zfs set compression=gzip mountpoint=/data/gzip compression/gzip
zfs create compression/gzip-9
zfs set compression=gzip-9 mountpoint=/data/gzip-9 compression/gzip-9
zfs create compression/lz4
zfs set compression=lz4 mountpoint=/data/lz4 compression/lz4
zfs create compression/lzjb
zfs set compression=lzjb mountpoint=/data/lzjb compression/lzjb
zfs create compression/zle
zfs set compression=zle mountpoint=/data/zle compression/zle
zfs get mounted

# downloading file to check the compression level
wget -O /data/gzip/War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
wget -O /data/gzip-9/War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
wget -O /data/lz4/War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
wget -O /data/lzjb/War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
wget -O /data/zle/War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8

tree /data/
zfs get compressratio

# Downloading file https://drive.google.com/open?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg' -O zfs_task1.tar.gz
tar -xvzf zfs_task1.tar.gz
zpool import -d zpoolexport otus
mkdir /data/otus
zfs set mountpoint=/data/otus otus/hometask2

# Checking properties
#   getting pool name and size
#   getting fs available size, type, record size, compression and checksum
zpool list -o name,size otus && zfs get available,type,recordsize,compression,checksum -o property,value otus

# Snapshot
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG' -O otus_task2.file
zfs receive otus/storage < otus_task2.file
zfs list -t snapshot
mount -t zfs otus/storage@task2 /mnt
find /mnt -name secret*
cat /mnt/task1/file_mess/secret_message