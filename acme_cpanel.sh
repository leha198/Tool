#!/bin/bash

# Retrieve domain and IP information, format it into pairs
output=$(uapi --output=jsonpretty DomainInfo domains_data | grep -E '"domain"|"ip"|"documentroot"' | awk -F': ' '{print $2}' | tr -d '",' | paste - - - | awk '{print $2, $1, $3}')
mapfile -t array <<< "$output"

# Check if the array is empty
if [[ ${#array[@]} -eq 0 ]]; then
    echo "No domains found."
    exit 1
fi

# Install acme.sh if not present
if [[ ! -f .acme.sh/acme.sh ]]; then
    curl -s https://get.acme.sh | sh -s email=acme.cpanel@gmail.com > /dev/null 2>&1
fi

PS3="Please select a domain (or enter 0 to exit): "
select choice in "${array[@]}"
do
    if [[ $REPLY == "0" ]]; then
        echo "Exit."
        break
    elif [[ -n $choice ]]; then
        # Extract domain and IP from the selected choice
        domain=$(echo "$choice" | awk '{print $1}')
        documentroot=$(echo "$choice" | awk '{print $2}')
        ip=$(echo "$choice" | awk '{print $3}')

        # Check if the DNS A record matches the selected IP
        resolved_ip=$(dig +short A "$domain")

        if [[ "$resolved_ip" == "$ip" ]]; then
            echo "DNS A record for $domain matches the provided IP: $ip"
            # Run the ACME get ssl command here
            echo "Running ACME get SSL for $domain..."
            .acme.sh/acme.sh --issue --webroot "$documentroot" -d "$domain"
            .acme.sh/acme.sh --deploy --deploy-hook cpanel_uapi --domain "$domain"
        else
            echo "Error: DNS A record for $domain does not match the provided IP. Resolved IP: $resolved_ip"
        fi

        break
    else
        echo "Invalid selection, please try again."
    fi
done
