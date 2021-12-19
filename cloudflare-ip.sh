#!/bin/bash
cf_ips() {
  for type in v4 v6; do
    echo "# IP$type"
    curl -s "https://www.cloudflare.com/ips-$type" | sed "s|^|allow |g" | sed "s|\$|;|g"
    echo
  done
  echo "# Generated at $(LC_ALL=C date)"
}
(cf_ips && echo "deny all;") > allow-cloudflare-only.conf
