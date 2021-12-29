#!/bin/bash
cf_ips() {
  for type in v4 v6; do
    echo "# IP$type"
    curl -s "https://www.cloudflare.com/ips-$type" | sed "s|^|set_real_ip_from |g" | sed "s|\$|;|g"
    echo
  done
  echo "# Generated at $(LC_ALL=C date)"
}
(cf_ips && echo "real_ip_header X-Forwarded-For;") > cloudflare.conf
