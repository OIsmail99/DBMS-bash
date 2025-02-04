#!/usr/bin/bash

while true; do
    
    read -p "SQL> " input

    
    standardInput=$(echo "$input" | sed 's/=/ = /g; s/  */ /g')

    
    dropKeyword=$(echo "$standardInput" | cut -d" " -f1)
    databaseKeyword=$(echo "$standardInput" | cut -d" " -f2)
    databaseName=$(echo "$standardInput" | cut -d" " -f3)

    
    if [[ ! "$dropKeyword" =~ ^[Dd][Rr][Oo][Pp]$ ]]; then
        echo "Error: Invalid Syntax."
        continue
    fi

    if [[ ! "$databaseKeyword" =~ ^[Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee]$ ]]; then
        echo "Error: Invalid Syntax."
        continue
    fi

    
    if [ ! -d "$databaseName" ]; then
        echo "Error: Database '$databaseName' does not exist."
        continue
    fi

    
    rm -r "$databaseName"
    echo "Database '$databaseName' dropped successfully."
    break

done


src/App/main_menu.sh