#!/bin/bash

PS3="Choose domain to install SSL: "

# Fetch domain list
domains=$(uapi --output=yaml DomainInfo domains_data | awk -F': ' '/domain:/ {print $2}' | sed '/^\s*$/d')

select domain in $domains; do
    # Fetch web directory and IP
    webdir=$(uapi --output=yaml DomainInfo domains_data | awk -v d="$domain" '/domain: / {if ($2 == d) {getline; getline; getline; getline; print $2}}' | sed 's/^[[:space:]]*//')
    ip=$(uapi --output=yaml DomainInfo domains_data | awk -v d="$domain" '/domain: / {if ($2 == d) {getline; getline; getline; getline; getline; getline; getline; getline; print $2}}' | sed 's/^[[:space:]]*//')

    # Get DNS records
    dns=$(dig +short A $domain | head -1)
    dns_w=$(dig +short A www.$domain | head -1)

    # Check DNS
    if [[ "$dns" == "$ip" || "$dns_w" == "$ip" ]]; then
        break
    else
        echo "Please point the $domain DNS record to $ip"
        exit 2
    fi
done

# Install acme.sh if not present
if [ ! -f .acme.sh/acme.sh ]; then
    curl -s https://get.acme.sh | sh -s email=acme.cpanel@gmail.com > /dev/null
fi

# Issue and deploy SSL
.acme.sh/acme.sh --issue --webroot $webdir -d $domain -d www.$domain
.acme.sh/acme.sh --deploy --deploy-hook cpanel_uapi --domain $domain --domain www.$domain
