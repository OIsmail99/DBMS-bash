#!/bin/bash

# Read the current database name
currentDatabase=$(cat ../data/current_database.txt 2>/dev/null)

# Capture full user input
input="$*"

# Check if a database is selected
if [[ ! -f "../data/current_database.txt" ]]; then
    echo "Error: No database selected."
    exit 1
fi

# Normalize input spacing and extract components
standardInput="$(echo "$input" | sed 's/[(),]/ & /g; s/  */ /g')"

# Extracting keywords and table name
selectField=$(echo "$standardInput" | awk '{print $1}')
fromField=$(echo "$standardInput" | awk '{print $2}')
table_name=$(echo "$standardInput" | awk '{print $3}')

# Validate SELECT command syntax
if [[ $selectField =~ ^[Ss][Ee][Ll][Ee][Cc][Tt]$ ]]; then
    if [[ $fromField =~ ^[Ff][Rr][Oo][Mm]$ ]]; then
        if [[ -n $table_name ]]; then
            if [[ -f "../data/$currentDatabase/$table_name" ]]; then
                cat "../data/$currentDatabase/$table_name"  # Display table content
            else
                echo "Error: Table '$table_name' does not exist"

                exit 1
            fi
        else
            echo "Error: Missing table name."
            exit 1
        fi
    else
        echo "Error: Invalid syntax. Expected 'FROM'."
        exit 1
    fi
else
    echo "Error: Invalid syntax. Expected 'SELECT'."
    exit 1
fi
