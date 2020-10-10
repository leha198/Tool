#!/bin/sh
clear
mkdir -p bkdata
user=`ls -1 /home`
function check {
    ls=`ls -l -Ibkdata -Ilog | awk '/^d/ {print $9}'`
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
}
function getdb {
    db_name=`grep 'DB_NAME' $cnf | awk -F"'" '{print $4}'`
    db_user=`grep 'DB_USER' $cnf | awk -F"'" '{print $4}'`
    db_pass=`grep 'DB_PASS' $cnf | awk -F"'" '{print $4}'`
}
function bkdb {
    getdb
    prefix=`grep '_prefix' $cnf | awk -F"'" '{print $2}'`
    mysqldump -u $db_user -p$db_pass $db_name > bkdata/$domain.sql
    if [ $? -eq 0 ]; then
        echo "Backup database successful"
    else
        echo "Backup database fail"
        sleep 2; exit
    fi
}
function bkcode {
    cd $domain
    tar -czf /home/$user/bkdata/$domain.gz DocumentRoot --exclude DocumentRoot/wp-config.php
    if [ $? -eq 0 ]; then
        echo "Backup code $domain successful"
    else
        echo "Backup code $domain fail"
    fi
}
function clone {
    ls=`ls -l -Ibkdata -Ilog -I$domain | awk '/^d/ {print $9}'`
    PS3="Choose domain restore:"
    select restore in $ls; do
        if [ -f $restore/wp-config.php ]; then
            cnf=$restore/wp-config.php
            break
        else
            echo "Please delete website and create website with wordpress"
        fi
    done
    getdb
    mysql -u $db_user -p$db_pass -e "drop database if exists $db_name;"
    mysql -u $db_user -p$db_pass -e "create database $db_name;"
    mysql -u $db_user -p$db_pass $db_name < bkdata/$domain.sql
    if [ $? -eq 0 ]; then
        echo "Restore database successful"
    else
        echo "Restore database fail"
        sleep 2; exit
    fi
    mysql -u $db_user -p$db_pass << EOF
use $db_name;
update ${prefix}options set option_value = 'http://$restore' where option_id = 1;
update ${prefix}options set option_value = 'http://$restore' where option_id = 2;
EOF
    cp -r $domain/DocumentRoot $restore > /dev/null 2>&1
    sed -i "s/wp_/$prefix/g" $cnf
    rm -rf bkdata
}
function menu {
    echo "~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "1. Backup website"
    echo "2. Clone website"
    echo "3. Exit"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~"
}
function pause {
    read -p "Press [Enter] key to menu..."
}

function option {
    read -p "Please enter choice:" choice
    case $choice in
        1 ) check; bkdb; bkcode; pause;;
        2 ) check; bkdb; clone; pause;;
        3 ) exit;;
        * ) echo "Error..."; sleep 1
    esac
}
while true
do
    menu
    option
done
