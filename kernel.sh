#!/bin/bash
os=`grep -oP "[0-9]+" /etc/redhat-release | head -1`
if [ $os = 7 ]; then
	yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
	yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
	echo "@reboot package-cleanup -y --oldkernels --count=1; crontab -r" > /var/spool/cron/root
elif [ $os = 8 ]; then
	dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
	dnf install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
	echo "@reboot dnf remove --oldinstallonly --setopt installonly_limit=2 kernel; crontab -r" > /var/spool/cron/root
fi

yum --enablerepo=elrepo-kernel install -y kernel-ml
grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg
