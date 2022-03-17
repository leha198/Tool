#!/bin/sh
mail1=
mail2=
pw1=
pw2=
for user in $(cat users.txt); do
imapsync --host1 $mail1 --user1 $user --password1 $pw1 --ssl1 --host2 $mail2 --user2 $user --password2 $pw2 --ssl2 --syncinternaldates --usecache --useheader "Message-Id"
done
