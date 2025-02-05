#!/bin/bash

# Read the current database name
currentDatabase=$(cat data/current_database.txt 2>/dev/null)

input=$*

# Check if a database is selected
if [[ ! -f "../data/current_database.txt" ]]; then
    echo "Error: No database selected."
    exit 1
fi
echo $input
# Parse input arguments, validate the * as well
standardInput=$(echo "$input" | sed 's/[(),]/ & /g; s/  */ /g')
echo $standardInput

selectField=$(echo "$standardInput" | cut -d" " -f1)
astresk=$(echo "$standardInput" | cut -d" " -f2)

fromField=$(echo "$standardInput" | cut -d" " -f3)
table_name=$(echo "$standardInput" | cut -d" " -f4)

echo $selectField
echo $astresk
echo $fromField
echo $table_name

# Validate SELECT command

if [[ $selectField =~ ^[Ss][Ee][Ll][Ee][Cc][Tt]$ ]]; then
    if [[ $astresk =~ ^\*$ ]]; then
        if [[ $fromField =~ ^[Ff][Rr][Oo][Mm]$ ]]; then
            if [[ -f "../data/$currentDatabase/$table_name" ]]; then
                echo "Table '$table_name' exists"
            else
                echo "Error: Table '$table_name' does not exist"
                exit 1
            fi
        else
            echo "Error: Invalid syntax."
            exit 1
        fi
    else
        echo "Error: Invalid syntax."
        exit 1
    fi
else
    echo "Error: Invalid syntax."
    exit 1
fi

# Display the table content
cat "../data/$currentDatabase/$table_name"