#!/usr/bin/bash

currentDatabase=$(cat ../data/current_database.txt 2>/dev/null)


if [[ ! -f "../data/current_database.txt" ]]; then
    echo "No database selected."
    exit 1
fi


input=$*
echo "Input: $input"


standardInput=$(echo "$input" | sed 's/[=]/ & /g; s/  */ /g')

# Parse the SQL query
deleteField=$(echo "$standardInput" | cut -d" " -f1)
fromField=$(echo "$standardInput" | cut -d" " -f2)
tableName=$(echo "$standardInput" | cut -d" " -f3)

whereField=$(echo "$standardInput" | cut -d" " -f4)
columnField=$(echo "$standardInput" | cut -d" " -f5)
equalField=$(echo "$standardInput" | cut -d" " -f6)
valueField=$(echo "$standardInput" | cut -d" " -f7)

# Validate DELETE FROM command
if [[ $deleteField =~ ^[Dd][Ee][Ll][Ee][Tt][Ee]$ ]]; then
    if [[ $fromField =~ ^[Ff][Rr][Oo][Mm]$ ]]; then
        # Validate table existence
        if [[ ! -f "../data/$currentDatabase/$tableName" ]]; then
            echo "Table '$tableName' does not exist."
            exit 1
        fi

        # Validate WHERE clause
        if [[ ! $whereField =~ ^[Ww][Hh][Ee][Rr][Ee]$ ]]; then
            echo "WHERE clause is missing. Use: DELETE FROM tableName WHERE column=value"
            exit 1
        fi

        # Validate column name
        if [[ ! $columnField =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            echo "Invalid column name."
            exit 1
        fi

        # Validate equal sign
        if [[ ! $equalField =~ ^[=]$ ]]; then
            echo "Invalid equal sign. Use: DELETE FROM tableName WHERE column=value"
            exit 1
        fi

        # Validate value
        if [[ -z $valueField ]]; then
            echo "Value cannot be empty."
            exit 1
        fi

        # Read metadata (first line of the table file)
        metadata=$(head -1 "../data/$currentDatabase/$tableName")

        # Check if the column exists in the metadata
        if ! echo "$metadata" | grep -q "$columnField"; then
            echo "Column '$columnField' does not exist in table '$tableName'."
            exit 1
        fi

        # Determine the column index
        columnIndex=$(echo "$metadata" | awk -F'[:,]' -v column="$columnField" '{
            for (i = 1; i <= NF; i++) {
                if ($i == column) {
                    print int((i + 2) / 3)  # Calculate the column index
                    break
                }
            }
        }')

        if [[ -z $columnIndex ]]; then
            echo "Column '$columnField' not found in table '$tableName'."
            exit 1
        fi

        # Delete the record
        awk -F'|' -v columnIndex="$columnIndex" -v value="$valueField" '
        NR == 1 { print }  # Print the metadata line
        NR > 1 {
            split($columnIndex, parts, ":")  # Split the column value to extract the actual value
            if (parts[1] != value) {
                print
            }
        }
        ' "../data/$currentDatabase/$tableName" > "../data/$currentDatabase/$tableName.tmp"

        mv "../data/$currentDatabase/$tableName.tmp" "../data/$currentDatabase/$tableName"

        echo "Record deleted successfully."
    else
        echo "Syntax error. Use: DELETE FROM tableName WHERE column=value"
        exit 1
    fi
else
    echo "Invalid command. Use: DELETE FROM tableName WHERE column=value"
    exit 1
fi

# Return to the submenu
./App/sub_menu.sh