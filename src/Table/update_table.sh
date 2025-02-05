#!/usr/bin/bash

read -p "SQL> " input

# Standardize input by adding spaces around operators and removing extra spaces
standardInput=$(echo "$input" | sed 's/=/ = /g; s/  */ /g')

#components of the input
updateKeyword=$(echo "$standardInput" | cut -d" " -f1)
tableName=$(echo "$standardInput" | cut -d" " -f2)
setKeyword=$(echo "$standardInput" | cut -d" " -f3)
columnName=$(echo "$standardInput" | cut -d" " -f4)
equalSign=$(echo "$standardInput" | cut -d" " -f5)
newValue=$(echo "$standardInput" | cut -d" " -f6)
whereKeyword=$(echo "$standardInput" | cut -d" " -f7)
conditionColumn=$(echo "$standardInput" | cut -d" " -f8)
conditionOperator=$(echo "$standardInput" | cut -d" " -f9)
conditionValue=$(echo "$standardInput" | cut -d" " -f10)

# Validate the query structure
if [[ ! "$updateKeyword" =~ ^[Uu][Pp][Dd][Aa][Tt][Ee]$ ]]; then
    echo "Error: Invalid UPDATE keyword."
    exit 1
fi

if [[ ! "$setKeyword" =~ ^[Ss][Ee][Tt]$ ]]; then
    echo "Error: Invalid SET keyword."
    exit 1
fi

if [[ "$equalSign" != "=" ]]; then
    echo "Error: Expected '=' after column name."
    exit 1
fi

if [[ ! "$whereKeyword" =~ ^[Ww][Hh][Ee][Rr][Ee]$ ]]; then
    echo "Error: Invalid WHERE keyword."
    exit 1
fi

# Validate table existence
if [ ! -f "$tableName" ]; then
    echo "Error: Table '$tableName' does not exist."
    exit 1
fi

# Read table metadata (first line)
metaData=$(head -1 "$tableName")

# Check if the column to update exists in the table
if ! echo "$metaData" | grep -qw "$columnName"; then
    echo "Error: Column '$columnName' does not exist in the table."
    exit 1
fi

# Check if the condition column exists in the table
if ! echo "$metaData" | grep -qw "$conditionColumn"; then
    echo "Error: Condition column '$conditionColumn' does not exist in the table."
    exit 1
fi


awk -v columnName="$columnName" -v newValue="$newValue" \
    -v conditionColumn="$conditionColumn" -v conditionOperator="$conditionOperator" \
    -v conditionValue="$conditionValue" -v metaData="$metaData" '
BEGIN {
    FS=":"
    OFS=":"
    # Split metadata into columns
    split(metaData, columns, ",")
    for (i in columns) {
        split(columns[i], meta, ":")
        columnNames[meta[1]] = i
    }
    # Validate condition operator
    if (conditionOperator != "==" && conditionOperator != "!=" && conditionOperator != ">" && conditionOperator != "<") {
        print "Error: Invalid condition operator. Use ==, !=, >, or <." > "/dev/stderr"
        exit 1
    }
}
NR == 1 {
    # Print the header (metadata)
    print $0 
    next
}
{
    # Check if the condition is met
    conditionMet = 0
    if (conditionOperator == "==" && $columnNames[conditionColumn] == conditionValue) {
        conditionMet = 1
    }
    if (conditionOperator == "!=" && $columnNames[conditionColumn] != conditionValue) {
        conditionMet = 1
    }
    if (conditionOperator == ">" && $columnNames[conditionColumn] > conditionValue) {
        conditionMet = 1
    }
    if (conditionOperator == "<" && $columnNames[conditionColumn] < conditionValue) {
        conditionMet = 1
    }
    # Update the column if the condition is met
    if (conditionMet) {
        $columnNames[columnName] = newValue
    }
    # Print the updated or unchanged line
    print $0
}
' "$tableName" > temp_table


mv temp_table "$tableName"

echo "Update completed successfully."