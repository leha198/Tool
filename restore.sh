#!/bin/sh
cd
user=`ls -1 /home`
domain=insertdomain
prefix=insertprefix
ls=`ls -l -Ilog -Ibkdata | awk '/^d/ {print $9}'`
PS3="Chose domain restore:"
select restore in $ls; do
	if [ -f $restore/wp-config.php ]; then
		cnf=$restore/wp-config.php
		break
	else
		echo "Please delete website and create website with wordpress"
		exit 2
	fi
done
rm -rf $restore/DocumentRoot
tar -xzf /home/$user/bkdata/$domain.gz --directory $restore
db_name=`grep 'DB_NAME' $cnf | awk -F"'" '{print $4}'`
db_user=`grep 'DB_USER' $cnf | awk -F"'" '{print $4}'`
db_pass=`grep 'DB_PASS' $cnf | awk -F"'" '{print $4}'`
db_prefix=`grep '_prefix' $cnf | awk -F"'" '{print $2}'`
mysql -u $db_user -p$db_pass -e "drop database if exists $db_name;"
mysql -u $db_user -p$db_pass -e "create database $db_name;"
mysql -u $db_user -p$db_pass $db_name < /home/$user/bkdata/$domain.sql
if [ $? -eq 0 ] ; then
	echo "Clone to $restore successful"
else
	echo "Clone to $restore fail"
fi
mysql -u $db_user -p$db_pass << EOF
use $db_name;
update ${prefix}options set option_value = 'http://$restore' where option_id = 1;
update ${prefix}options set option_value = 'http://$restore' where option_id = 2;
EOF
sed -i "s/$db_prefix/$prefix/g" $cnf
rm -rf bkdata; exit
