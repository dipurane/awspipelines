#!/bin/bash

# Input arguments
source=$1
destination=$2
interval=$3
backupNum=$4
efsid=$5
clientNum=$6
numClients=$7
WEBDIR=/mnt/backups/rsync/hourly.1

# Prepare system for rsync
echo 'sudo yum -y install nfs-utils'
sudo yum -y install nfs-utils

if [ ! -d /backup ]; then
  echo 'sudo mkdir /backup'
  sudo mkdir /backup
  echo "sudo mount -t nfs -o nfsvers=4.1 -o rsize=1048576 -o wsize=1048576 -o timeo=600 -o retrans=2 -o hard $source /backup"
  sudo mount -t nfs -o nfsvers=4.1 -o rsize=1048576 -o wsize=1048576 -o timeo=600 -o retrans=2 -o hard $source /backup
fi
sleep 10
if [ ! -d /mnt/backups ]; then
  echo 'sudo mkdir /mnt/backups'
  sudo mkdir /mnt/backups
  echo "sudo mount -t nfs -o nfsvers=4.1 -o rsize=1048576 -o wsize=1048576 -o timeo=600 -o retrans=2 -o hard $destination /mnt/backups"
  sudo mount -t nfs -o nfsvers=4.1 -o rsize=1048576 -o wsize=1048576 -o timeo=600 -o retrans=2 -o hard $destination /mnt/backups
fi
sleep 10
if [ -f /tmp/efs-restore.log ]; then
  echo "sudo rm /tmp/efs-restore.log"
  sudo rm /tmp/efs-restore.log
fi

echo "Slepping for 20 Seconds"

sleep 20

echo "Slept for 20 Seconds"

if [ -d "$WEBDIR" ]; then
  echo "$WEBDIR exists; Directory mounted"
else
  echo "$WEBDIR Doesnt exists; Directory not mounted"
fi


#Copy all content this node is responsible for
  echo "sudo rsync -ah --stats --delete --numeric-ids --log-file=/tmp/efs-restore.log /mnt/backups/$efsid/$interval.$backupNum /backup/"
  sudo rsync -ah --stats --delete --numeric-ids --log-file=/tmp/efs-restore.log /mnt/backups/$efsid/$interval.$backupNum/$myContent /backup/
  rsyncStatus=$?

if [ -f /tmp/efs-restore.log ]; then
echo "sudo cp /tmp/efs-restore.log /mnt/backups/efsbackup-logs/$efsid-$interval.$backupNum-restore-$clientNum.$numClients-`date +%Y%m%d-%H%M`.log"
sudo cp /tmp/efs-restore.log /mnt/backups/efsbackup-logs/$efsid-$interval.$backupNum-restore-$clientNum.$numClients-`date +%Y%m%d-%H%M`.log
fi
exit $rsyncStatus
