#! /usr/bin/bash

# Read the current database name
currentDatabase=$(cat ../data/current_database.txt 2>/dev/null)

# Validate if a database is selected
if [[ ! -f "../data/current_database.txt" ]]; then
    echo "Error: No database selected."
    ./App/sub_menu.sh
    exit 1
fi

# Parse input arguments
input=$*
standardInput=$(echo "$input" | sed 's/[(),]/ & /g; s/  */ /g')
createField=$(echo "$standardInput" | cut -d" " -f1)
tableField=$(echo "$standardInput" | cut -d" " -f2)
tableName=$(echo "$standardInput" | cut -d" " -f3)
columns=$(echo "$standardInput" | sed 's/.*(//;s/).*//')

# Validate CREATE TABLE command
if [[ $createField =~ ^[Cc][Rr][Ee][Aa][Tt][Ee]$ ]]; then
    if [[ $tableField =~ ^[Tt][Aa][Bb][Ll][Ee]$ ]]; then
        # Validate table name
        if [[ ! $tableName =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            echo "Error: Invalid table name."
            exit 1
        fi

        # Check if table already exists
        if [[ -f "../data/$currentDatabase/$tableName" ]]; then
            echo "Error: Table '$tableName' already exists."
            exit 1
        fi

        # Validate columns
        if [[ -z $columns ]]; then
            echo "Error: No columns specified."
            exit 1
        fi

        # Process columns and generate metadata
        echo "$columns" | awk -F' , ' '
        BEGIN {
            pkStatus = 0
            line = ""
        }
        {
            for (i = 1; i <= NF; i++) {
                column = $i
                split(column, items, " ")
                columnName = items[1]
                dataType = toupper(items[2])
                primaryKeyConstraint = items[3] " " items[4]

                # Validate data type
                if (dataType != "INT" && dataType != "STRING" && dataType != "BOOLEAN") {
                    print "Error: Invalid data type " dataType > "/dev/stderr"
                    exit 1
                }

                # Handle primary key constraint
                if (primaryKeyConstraint ~ /^[Pp][Rr][Ii][Mm][Aa][Rr][Yy][[:space:]]+[Kk][Ee][Yy]$/ && pkStatus == 0) {
                    pkStatus = 1
                    line = line columnName ":" dataType ":PK,"
                } else if (primaryKeyConstraint ~ /^[Pp][Rr][Ii][Mm][Aa][Rr][Yy][[:space:]]+[Kk][Ee][Yy]$/) {
                    print "Error: Only one primary key is allowed." > "/dev/stderr"
                    exit 1
                } else if (i != NF) {
                    line = line columnName ":" dataType ","
                } else {
                    line = line columnName ":" dataType
                }
            }
        }
        END {
            if (line != "") print line
        }' > "../data/$currentDatabase/$tableName"

        # Check if the file was created successfully
        if [[ ! -s "../data/$currentDatabase/$tableName" ]]; then
            rm -f "../data/$currentDatabase/$tableName"
            echo "Error: Failed to create table '$tableName'."
            exit 1
        else
            echo "Table '$tableName' created successfully."
        fi
    else
        echo "Error: Invalid command. Expected 'TABLE'."
        exit 1
    fi
else
    echo "Error: Invalid command. Expected 'CREATE'."
    exit 1
fi
./App/sub_menu.sh