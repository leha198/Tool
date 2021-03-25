#!/bin/sh
clear
echo "Dang quet ma doc..."
user=$(ls -1 /home)
grep -r --include \*.php '\\x[0-9][0-9]\\x[0-9][a-z]\\x[0-9][0-9]\\x[0-9][a-z]\\' | tr -d [:blank:] > malware
for i in $(cat malware); do
	length=${#i}
	if [ $length -ge 250 ]; then
	echo $(echo $i | cut -d: -f1) >> result
	fi
done
grep -r --include \*.php '$user_agent_to_filter = array\|eval (gzinflate(base64_decode' | cut -d: -f 1 >> result
find * -name '*.php.suspected' -o -name '.*.ico' >> result
sort -u result > $user.txt
rm -f result malware
if [ -s $user.txt ]; then	
	echo "Da tim thay ma doc. Danh sach ma doc trong $user.txt"
else
	echo "Khong tim thay ma doc"
	rm -f $user.txt
fi
