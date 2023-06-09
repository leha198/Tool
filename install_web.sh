#!/bin/bash
PS3="Chose domain: "
select domain in `uapi --output=yaml DomainInfo domains_data | grep "domain:" | awk -F':' '{print $2}' | sed '/^\s*$/d'`; do
	webdir=`uapi --output=yaml DomainInfo domains_data | grep "domain: ${domain}" -B1 | grep "documentroot" | awk '{print $2}'`
	#Check Wordpress install
	if [ -f "${webdir}/wp-config.php" ]; then
		break
	else
		echo "${domain} does not have Wordpress installed, please install Worpdress."
		exit 2
	fi
done

PS3="Chose theme: "
select i in store-{1,2,3,4,5,6,7,8} news-{1,2,3,4,5,6,7} bds-{1,2,3} travel-{1,2}; do
	wb=`echo ${i} | awk -F'-' '{print $1}'`
	wi=`echo ${i} | awk -F'-' '{print $2}'`
	if [ "${wb}" = store ]; then
		id=tentenwordpress1"${wi}"
		break
	elif [ "${wb}" = news ]; then
		id=tentenwordpress"${wi}"
		break
	elif [ "${wb}" = bds ]; then
		id=tentenwordpress2"${wi}"
		break
	elif [ "${wb}" = travel ]; then
		id=tentenwordpress3"${wi}"
		break
	fi
done
src_url="failoverhosting.com.vn"
admin_pw=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 12`
wpcli="/opt/alt/php74/usr/bin/php ${webdir}/wp"
cd ${webdir}
wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O wp
${wpcli} core install --url=${domain} --title=Theme --admin_user=admin --admin_password=${admin_pw} --admin_email=tenten@gmail.com > /dev/null
${wpcli} option update home "http://${domain}" > /dev/null
${wpcli} option update siteurl "http://${domain}" > /dev/null
wget -q ${src_url}/all-in-one-wp-migration-unlimited-extension.zip -O all-in-one-wp-migration-unlimited-extension.zip
wget -q ${src_url}/all-in-one-wp-migration.zip -O all-in-one-wp-migration.zip
${wpcli} plugin install all-in-one-wp-migration.zip --activate > /dev/null
${wpcli} plugin install all-in-one-wp-migration-unlimited-extension.zip --activate > /dev/null
wget -q ${src_url}/${id}.wpress -O wp-content/ai1wm-backups/${id}.wpress
${wpcli} ai1wm restore ${id}.wpress --yes > /dev/null
${wpcli} plugin deactivate all-in-one-wp-migration all-in-one-wp-migration-unlimited-extension > /dev/null
${wpcli} plugin delete all-in-one-wp-migration all-in-one-wp-migration-unlimited-extension > /dev/null
${wpcli} user create admin tenten@gmail.com --role=administrator --user_pass=${admin_pw} > /dev/null
${wpcli} user delete admin_dev --reassign=admin > /dev/null
rm -rf ${webdir}/wp ${webdir}/wp-content/ai1wm-backups ${webdir}/all-in-one-wp-migration.zip ${webdir}/all-in-one-wp-migration-unlimited-extension.zip
echo ""
echo "======================================="
echo "Your website was created successfully"
echo "http://"${domain}"/wp-admin"
echo "Account:  admin"
echo "Password: ${admin_pw}"
