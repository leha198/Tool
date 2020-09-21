#!/bin/bash
clear
ls=$(ls -l -Ibkdata -Ilog|awk '/^d/ {print $9}')
PS3="Chose domain backup:"
select domain in $ls; do
	if [[ -d $domain ]]; then
		break
	fi
done
rm -rf bkdata
mkdir -p bkdata
root=$domain/DocumentRoot
if [[ -f $root/wp-config.php ]]; then
	cg=$root/wp-config.php
elif [[ -f $domain/wp-config.php ]]; then
	cg=$domain/wp-config.php
else
	echo "Website not running Wordpress..."
	sleep 2 && exit
fi
db_name=$(grep DB_NAME $cg |cut -d "'" -f 4)
db_user=$(grep DB_USER $cg | cut -d "'" -f 4)
db_pass=$(grep DB_PASSWORD $cg | cut -d "'" -f 4)
table_prefix=$(grep '$table_prefix' $cg | cut -d "'" -f 2)
mysqldump -u $db_user -p$db_pass $db_name > bkdata/$domain.sql
if [ $? -eq 0 ] ; then
	echo "Backup database successful"
else
	echo "Backup database fail"
	sleep 2 && exit
fi
dir=$(pwd)
cd $domain
tar -cf $dir/bkdata/$domain.gz DocumentRoot --exclude DocumentRoot/wp-content/cache --exclude DocumentRoot/wp-config.php
echo "Backup code successful" && cd
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
wget -q script.lehait.net/host/restore.sh -O bkdata/restore.sh
sed -i -e "s/backupdomain/$domain/g" -e "s/backupprefix/$table_prefix/g" bkdata/restore.sh
transfer(){
	read -p "Another Host:" host
	read -p "User SFTP:" acc
	scp -r -P 9090 bkdata $acc@$host:/home/$acc/
}
transfer
while [ $? -ge 1 ]; do
	echo "Transfer fail..." && transfer
done
ssh -p 9090 $acc@$host "cd bkdata && sh restore.sh"
rm -rf bkdata copy.sh
