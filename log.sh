#!/bin/sh
if php53 -v > /dev/null 2>&1; then
        log="php-fpm php53-fpm php7-fpm php71-fpm php72-fpm php73-fpm php74-fpm"
else
        log="php-fpm php7"
fi
user=`ls -1 /home`
for php in $log; do
        mkdir -p /home/$user/log/$php/session
done
if [ -d /home/$user/log ]; then
        echo "Create log successful, please restart php"
else
        echo "Fail, full disk or inode"
fi
