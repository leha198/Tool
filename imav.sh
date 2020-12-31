#!/bin/sh
systemctl stop imunify-antivirus
sqlite3 /var/imunify360/imunify360.db <<EOF
PRAGMA foreign_keys = ON;
DELETE FROM malware_scans where total_malicious = 0;
EOF
systemctl start imunify-antivirus
