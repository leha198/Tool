#!/bin/bash
PS3="Chose domain install SSL: "
select domain in `uapi --output=yaml DomainInfo domains_data | grep "domain:" | awk -F':' '{print $2}' | sed '/^\s*$/d'`; do
	webdir=`uapi --output=yaml DomainInfo domains_data | grep "domain: ${domain}" -B1 | grep "documentroot" | awk '{print $2}'`
	ip=`uapi --output=yaml DomainInfo domains_data | grep "domain: ${domain}" -A4 | grep "ip" | awk '{print $2}'`
	dns=`dig +short A ${domain} | head -1`
	dns_w=`dig +short A www.${domain} | head -1`
	#Check DNS domain
	if [ "${dns}" = "${ip}" ] || [ "${dns_w}" = "${ip}" ]; then
		break
	else
		echo "Please point the ${domain} DNS record to ${ip}"
		exit 2
	fi
done
#Issue SSL domain
if [ ! -f .acme.sh/acme.sh ]; then
	curl https://get.acme.sh | sh -s email=acme.cpanel@gmail.com > /dev/null 2>&1
fi
.acme.sh/acme.sh --issue --webroot ${webdir} -d ${domain} -d www.${domain}
.acme.sh/acme.sh --deploy --deploy-hook cpanel_uapi --domain ${domain} --domain www.${domain}
