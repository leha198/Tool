#!/bin/sh
clear
mkdir -p bkdata
user=`ls -1 /home`
ls=`ls -l -Ibkdata -Ilog|awk '/^d/ {print $9}'`
PS3="Chose domain backup:"
select domain in $ls; do
	if [ -f $domain/DocumentRoot/wp-config.php ]; then
		cnf=$domain/DocumentRoot/wp-config.php
		break
	elif [ -f $domain/wp-config.php ]; then
		cnf=$domain/wp-config.php
		break
	else
		echo "Website not running wordpress..."
		sleep 2; exit
	fi
done
db_name=`grep 'DB_NAME' $cnf | awk -F"'" '{print $4}'`
db_user=`grep 'DB_USER' $cnf | awk -F"'" '{print $4}'`
db_pass=`grep 'DB_PASS' $cnf | awk -F"'" '{print $4}'`
prefix=`grep '_prefix' $cnf | awk -F"'" '{print $2}'`
mysqldump -u $db_user -p$db_pass $db_name > bkdata/$domain.sql
if [ $? -eq 0 ] ; then
	echo "Backup database $domain successful"
else
	echo "Backup database $domain fail"
	sleep 2; exit
fi
cd $domain
tar -czf /home/$user/bkdata/$domain.gz DocumentRoot --exclude DocumentRoot/wp-config.php
if [ $? -eq 0 ]; then
    echo "Backup code $domain successful"
else
    echo "Backup code $domain fail"
fi
cd
wget -q script.lehait.net/restore.sh -O bkdata/restore.sh
sed -i -e "s/insertdomain/$domain/g" -e "s/insertprefix/$prefix/g" bkdata/restore.sh
function remote {
	while read -p "Copy to server:" host; do
		if [ ! -z $host ]; then
			break
		fi
	done
	while read -p "User SFTP:" account; do
		if [ ! -z $account ]; then
			break
		fi
	done
}
while remote; do
	scp -r -P 9090 bkdata $account@$host:/home/$account
	if [ $? -eq 0 ]; then
		break
	fi
done
ssh -p 9090 $account@$host "cd bkdata; sh restore.sh"
rm -rf bkdata $0
