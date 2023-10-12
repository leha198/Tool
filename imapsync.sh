#!/bin/bash
function migrate_email {
#Info server email
src_server=
des_server=
pwd=
#Options migrate from zimbra
zm_user=
zm_pass=
email="$1"
NORMAL="--host1 $src_server --password1 $pwd --ssl1 --host2 $des_server --password2 $pwd --ssl2"
ZIMBRA="--host1 $src_server --authuser1 $zm_user --password1 $zm_pass --ssl1 --host2 $des_server --password2 $pwd --ssl2"
#Change NORMAL or ZIMBRA
	imapsync --buffersize 8192000 $ZIMBRA --user1 "$email" --user2 "$email" --syncinternaldates --addheader --useheader "Message-Id"
}

function install_package {
    OS=$(uname -r | sed -n 's/^.*\(el[0-9]\+\).*$/\1/p')
    # Check if imapsync is already installed
    if rpm -q imapsync &> /dev/null; then
        echo "imapsync is already installed."
    else
        if [ "$OS" == "el7" ]; then
            yum install imapsync -y &> /dev/null
        elif [ "$OS" == "el8" ]; then
            yum install --enablerepo=powertools imapsync -y &> /dev/null
        else
            echo "Unsupported OS version."
            exit 1  # Exit the script with an error status
        fi
    fi
    # Install parallel on both RHEL 7 and RHEL 8
    yum install parallel -y &> /dev/null
}
# Call the function to install the packages
install_package

export -f migrate_email
#Read email addresses from the file and run migrations in parallel
cat "users.txt" | parallel -j 3 --delay 2 migrate_email
unset -f migrate_email
