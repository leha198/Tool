#!/bin/sh
service imunify-antivirus stop
sqlite3 /var/imunify360/imunify360.db <<EOF
DELETE FROM malware_history;
DELETE FROM malware_hits;
DELETE FROM malware_scans;
DELETE FROM malware_user_infected;
EOF
service imunify-antivirus start
