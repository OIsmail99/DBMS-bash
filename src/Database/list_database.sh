#!/usr/bin/bash

read -p "SQL> " input
standardInput=$(echo "$input" | sed 's/=/ = /g; s/  */ /g')
showKeyword=$(echo "$standardInput" | cut -d" " -f1)
databaseKeyword=$(echo "$standardInput" | cut -d" " -f2)
if [[ ! "$showKeyword" =~ ^[Ss][Hh][Oo][Ww]$ ]]; then
    echo "Error: Invalid SHOW keyword."
    exit 1
fi

if [[ ! "$databaseKeyword" =~ ^[Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee][Ss]$ ]]; then
    echo "Error: Invalid DATABASES keyword."
    exit 1
fi

ls -d */

src/App/main_menu.sh