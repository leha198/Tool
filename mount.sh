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
echo -e "o\nn\np\n1\n\n\nw" $disk
part=`fdisk -l $disk | sed -n '/^[/]/p' | awk '{print $1}'`
mkdir -p /backup_data
mkfs.xfs $part > /dev/null 2>&1
mount $part /backup_data
echo "======================================================================"
echo "Start sync data to external disk"
rsync -avzh $dir/ /backup_data
umount $part
rm -rf $dir/* /backup_data
mount $part $dir
echo "$part $dir  xfs  defaults,uquota,gquota,nofail  0 0" >> /etc/fstab
read -p "The process mount successful. Do you want to restart the server? [Y/n]: " boot
if [ "$boot" = "Y" ] || [ "$boot" = "y" ] || [ -z "$boot" ]; then
        reboot
fi
#Destroy disk
#wipefs -a /dev/vdb
