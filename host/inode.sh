#!/bin/bash
clear
echo "Inode statistics for: $(pwd)"
for d in `ls -1A`; do
        c=$(find $d | wc -l)
        echo -e "$c\t - $d"
        done
echo "Total: $(find $(pwd) | wc -l) file"
