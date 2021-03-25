#!/bin/sh
function install_cyber {
wget -O cyberpanel.sh https://cyberpanel.net/install.sh
chmod +x cyberpanel.sh
./cyberpanel.sh -v ols -p r
find /usr/local/lsws -type f -name "php.ini" | xargs sed -i -e 's/2M/1024M/g' -e 's/128M/256M/g' -e 's/8M/1024M/g'
find /usr/local/lsws -type f -name "php.ini" | xargs sed -i -e 's/time = 30/time = 1000/g' -e 's/time = 60/time = 1000/g'
pass=`cat /etc/cyberpanel/mysqlPassword`
mysql -u root -p$pass <<EOF	
use cyberpanel;	
update packages_package set diskSpace = '0' where id = '1';	
update packages_package set bandwidth = '0' where id = '1';	
update packages_package set allowedDomains = '0' where id = '1';	
EOF
}
function install {
if [ -f /etc/redhat-release ]; then
	echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
	sysctl -p
	yum update -y
	install_cyber
	echo "max_allowed_packet=1024M" >> /etc/my.cnf
elif [ -f /etc/lsb-release ]; then
	apt update; apt upgrade -y
	install_cyber
	echo "max_allowed_packet=1024M" >> /etc/mysql/my.cnf
fi
rm -rf cyberpanel*
}
if [ -d /usr/local/CyberCP ]; then
	curl https://raw.githubusercontent.com/usmannasir/cyberpanel/stable/preUpgrade.sh | sh
else
	install
fi
