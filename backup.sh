#!/bin/bash
usr="/home/$(whoami)"
src_url="failoverhosting.com.vn"

function plugin_act {
    wget -q ${src_url}/all-in-one-wp-migration.zip -O all-in-one-wp-migration.zip
    wget -q ${src_url}/all-in-one-wp-migration-unlimited-extension.zip -O all-in-one-wp-migration-unlimited-extension.zip
    php74 wp plugin install all-in-one-wp-migration.zip --activate > /dev/null
    php74 wp plugin install all-in-one-wp-migration-unlimited-extension.zip --activate > /dev/null
}

function plugin_deact {
    php74 wp plugin deactivate all-in-one-wp-migration all-in-one-wp-migration-unlimited-extension > /dev/null
    php74 wp plugin delete all-in-one-wp-migration all-in-one-wp-migration-unlimited-extension > /dev/null
    rm -rf wp all-in-one-wp-*.zip wp-content/ai1wm-backups
}

function backup {
    PS3="Chose domain backup:"
    select domain in `ls -l -Ilog | awk '/^d/ {print $9}'`; do
        if [ -d ${domain}/DocumentRoot/wp-content ]; then
            break
        else
            echo "Script only support WordPress..."
            exit 2
        fi
    done
    cd ${usr}/${domain}/DocumentRoot
    wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O wp
    plugin_act
    bk_file=`php74 wp ai1wm backup | grep "location" | awk '{print $3}'`
    mv -f ${bk_file} ${usr}/${domain}.wpress
    plugin_deact
}

function restore {
    cd ${usr}
        PS3="Chose domain restore:"
        select dm in `ls -l -Ilog -I${domain} | awk '/^d/ {print $9}'`; do
            if [ -d ${dm}/DocumentRoot/wp-content ]; then
                    break
            else
                    echo "Script only support WordPress..."
                    exit 2
            fi
    done

    cd ${usr}/${dm}/DocumentRoot
    admin_pw=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 12`
    wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O wp
    php74 wp core install --url=${dm} --title=Blog --admin_user=admin --admin_password=${admin_pw} --admin_email=tenten@gmail.com --skip-email > /dev/null
    php74 wp option update home "http://${dm}" > /dev/null
    php74 wp option update siteurl "http://${dm}" > /dev/null
    plugin_act
    mv -f ${usr}/${domain}.wpress wp-content/ai1wm-backups/${domain}.wpress
    php74 wp ai1wm restore ${domain}.wpress --yes > /dev/null
    plugin_deact
}

function sftp {
    while read -p "Copy to server:" host; do
        if [ ! -z ${host} ]; then
            ip=`curl -s failoverhosting.com.vn/secureweb/listsrv | grep ${host} | awk -F':' '{print $2}'`
            break
        fi
    done
    while read -p "User SFTP:" user; do
        if [ ! -z ${user} ]; then
            break
        fi
    done
}

function remote {
    cd ${usr}
    wget -q https://raw.githubusercontent.com/leha198/script/master/restore.sh -O restore.sh
    sed -i "s|domain_ins|${domain}|g" restore.sh
    while sftp; do
        scp -P 9090 ${domain}.wpress restore.sh ${user}@${ip}:/home/${user}
        if [ $? -eq 0 ]; then
            break
        fi
    done
    ssh -p 9090 ${user}@${ip} "sh restore.sh; rm -f restore.sh"
    rm -f ${domain}.wpress restore.sh
}

function menu {
    echo "=================================="
    echo "1. Clone website"
    echo "2. Copy website to another server"
    echo "3. Exit"
    echo "=================================="
}

function pause {
    read -p "Press [Enter] key to menu..."
}

function option {
    read -p "Please enter choice:" choice
    case $choice in
        1 ) backup
            restore
            exit
        ;;
        2 ) backup
            remote
            exit
        ;;
        * ) echo "Error..."; sleep 1
    esac
}
while true
do
    menu
    option
done
