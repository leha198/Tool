#!/bin/bash
#Install cyberpanel
cyber(){
wget -O cyberpanel.sh https://cyberpanel.net/install.sh
chmod +x cyberpanel.sh
./cyberpanel.sh -v ols -p r
find /usr/local/lsws -type f -name "php.ini" | xargs sed -i -e 's/2M/1024M/g' -e 's/128M/256M/g' -e 's/8M/1024M/g'
find /usr/local/lsws -type f -name "php.ini" | xargs sed -i -e 's/time = 30/time = 300/g' -e 's/time = 60/time = 300/g'
sqlpw=`cat /etc/cyberpanel/mysqlPassword`
mysql -u root -p$sqlpw <<EOF	
use cyberpanel;	
update packages_package set diskSpace = '0' where id = '1';	
update packages_package set bandwidth = '0' where id = '1';	
update packages_package set allowedDomains = '0' where id = '1';	
EOF
}
#Check OS and install
install(){
if [ -f /etc/redhat-release ]; then
	yum update -y
	cyber
	echo "max_allowed_packet=1024M" >> /etc/my.cnf
elif [ -f /etc/lsb-release ]; then
	apt update -y && apt upgrade -y
	cyber
	echo "max_allowed_packet=1024M" >> /etc/mysql/my.cnf
fi
rm -rf cyberpanel*
}
#Check install cyberpanel
if [ -d /usr/local/CyberCP ]; then
	echo "Cyberpanel be installed."
	cyberpanel upgrade
else
	echo "OS not installed Cyberpanel. Start install Cyberpanel"
	sleep 2 && install
fi
