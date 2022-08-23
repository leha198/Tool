#!/bin/bash
mail1=
mail2=
pw=
for user in $(cat users.txt); do
    imapsync --host1 $mail1 --user1 $user --password1 $pw --ssl1 --host2 $mail2 --user2 $user --password2 $pw --ssl2 --syncinternaldates --usecache --useheader "Message-Id"
done
