#!/bin/bash
currentDatabase=$(cat ../data/current_database.txt 2>/dev/null)
# Read the current database name

# Capture full user input

table_name=$1
# Check if a database is selected
if [[ ! -f "../data/current_database.txt" ]]; then
    echo "Error: No database selected."
    exit 1
fi


#validate the sql syntax




if [[ ! -f "../data/$currentDatabase/$table_name" ]]; then
    echo "Error: Table '$table_name' does not exist"
    exit 1
fi

rm -rf "../data/$currentDatabase/$table_name"

echo "Table '$table_name' dropped successfully"
exit 0
