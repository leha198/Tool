#!/bin/bash
if [ -f list_domain.csv ]; then
        rm -f list_domain.csv
else 
        echo "Domain,Issue Date,Expired Date,Registrar Name,Owner Name,IP" >> list_domain.csv
fi
for d in `cat info.txt`; do
        iss=`curl -H "Content-Type: text/html; charset=UTF-8" "https://whois.net.vn/whois.php?domain=$d&act=getwhois" | grep "Issue Date" | awk -F':' '{print $2}' | awk -F'<' '{print $1}'| iconv -f utf8 -t ascii//TRANSLIT`
        exp=`curl -H "Content-Type: text/html; charset=UTF-8" "https://whois.net.vn/whois.php?domain=$d&act=getwhois" | grep "Expired Date" | awk -F':' '{print $2}' | awk -F'<' '{print $1}'| iconv -f utf8 -t ascii//TRANSLIT`
        own=`curl -H "Content-Type: text/html; charset=UTF-8" "https://whois.net.vn/whois.php?domain=$d&act=getwhois" | grep "Owner Name" | awk -F':' '{print $2}' | awk -F'<' '{print $1}'| iconv -f utf8 -t ascii//TRANSLIT`
        reg=`curl -H "Content-Type: text/html; charset=UTF-8" "https://whois.net.vn/whois.php?domain=$d&act=getwhois" | grep "Registrar Name" | awk -F':' '{print $2}' | awk -F'<' '{print $1}'| iconv -f utf8 -t ascii//TRANSLIT`
        ip=`dig +short $d | head -n1`
        echo "$d,$iss,$exp,$reg,$own,$ip" >> list_domain.csv
done