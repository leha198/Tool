#!/bin/sh
systemctl stop imunify-antivirus
sqlite3 /var/imunify360/imunify360.db <<EOF
DELETE FROM malware_history;
DELETE FROM malware_hits;
DELETE FROM malware_scans;
EOF
systemctl start imunify-antivirus
