#!/bin/bash
while read -p "Folder need mount:" dir
do      if [ -d $dir ]; then
		break
	else
		echo "Folder $dir not found, try again"
	fi
done
disk=`parted -l 2>&1 > /dev/null | awk -F ':' {'print $2'} | grep -Ev '[0-9]$|Warning|Read-only'`
if [ -n "$disk" ]; then
        echo "External disk ready to format and mount"
else
        echo "No external disk found"
	exit 2
fi
#Start mount data to external disk
mkdir -p /backup_data
mkfs.xfs $disk > /dev/null 2>&1
mount $disk /backup_data
echo "======================================================================"
echo "Start sync data to external disk"
rsync -avzh $dir/ /backup_data
umount $disk
rm -rf $dir/* /backup_data
mount $disk $dir
echo "$disk $dir ext4 defaults 0 1" >> /etc/fstab
read -p "The process mount successful. Do you want to restart the server? [Y/n]: " boot
if [ "$boot" = "Y" ] || [ "$boot" = "y" ] || [ -z "$boot" ]; then
        reboot
fi
#Destroy disk
#wipefs -a /dev/vdb
