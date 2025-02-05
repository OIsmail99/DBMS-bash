#!/usr/bin/bash


currentDatabase=$(cat ../data/current_database.txt 2>/dev/null)


if [[ ! -f "../data/current_database.txt" ]]; then
    echo "Error: No database selected."
    exit 1
fi


input=$*


standardInput=$(echo "$input" | sed 's/=/ = /g; s/  */ /g')


updateKeyword=$(echo "$standardInput" | cut -d" " -f1)
tableName=$(echo "$standardInput" | cut -d" " -f2)
setKeyword=$(echo "$standardInput" | cut -d" " -f3)
columnName=$(echo "$standardInput" | cut -d" " -f4)
equalSignSet=$(echo "$standardInput" | cut -d" " -f5)  # Operator in SET clause
newValue=$(echo "$standardInput" | cut -d" " -f6)
whereKeyword=$(echo "$standardInput" | cut -d" " -f7)
conditionColumn=$(echo "$standardInput" | cut -d" " -f8)
equalSignCondition=$(echo "$standardInput" | cut -d" " -f9)  # Operator in WHERE condition
conditionValue=$(echo "$standardInput" | cut -d" " -f10)


if [[ ! "$updateKeyword" =~ ^[Uu][Pp][Dd][Aa][Tt][Ee]$ ]]; then
    echo "Error: Invalid UPDATE keyword. Use: UPDATE tableName SET column=value WHERE column=value"
    exit 1
fi

if [[ ! "$setKeyword" =~ ^[Ss][Ee][Tt]$ ]]; then
    echo "Error: Invalid SET keyword. Use: UPDATE tableName SET column=value WHERE column=value"
    exit 1
fi


if [[ "$equalSignSet" != "=" ]]; then
    echo "Error: Expected '=' in SET clause. Use: UPDATE tableName SET column=value WHERE column=value"
    exit 1
fi

if [[ ! "$whereKeyword" =~ ^[Ww][Hh][Ee][Rr][Ee]$ ]]; then
    echo "Error: Invalid WHERE keyword. Use: UPDATE tableName SET column=value WHERE column=value"
    exit 1
fi


if [[ "$equalSignCondition" != "=" ]]; then
    echo "Error: Expected '=' in WHERE condition. Use: UPDATE tableName SET column=value WHERE column=value"
    exit 1
fi


if [[ ! -f "../data/$currentDatabase/$tableName" ]]; then
    echo "Error: Table '$tableName' does not exist."
    exit 1
fi


metaData=$(head -1 "../data/$currentDatabase/$tableName")


if ! echo "$metaData" | grep -qw "$columnName"; then
    echo "Error: Column '$columnName' does not exist in the table."
    exit 1
fi


if ! echo "$metaData" | grep -qw "$conditionColumn"; then
    echo "Error: Condition column '$conditionColumn' does not exist in the table."
    exit 1
fi


awk -v columnName="$columnName" -v newValue="$newValue" \
    -v conditionColumn="$conditionColumn" -v conditionValue="$conditionValue" \
    -v metaData="$metaData" '
BEGIN {
    FS=":"
    OFS=":"
    # Split metadata into columns
    split(metaData, columns, ",")
    for (i in columns) {
        split(columns[i], meta, ":")
        columnNames[meta[1]] = i
    }
}
NR == 1 {
    # Print the header (metadata)
    print $0
    next
}
{
    # Check if the condition is met (only = is allowed)
    if ($columnNames[conditionColumn] == conditionValue) {
        # Update the column
        $columnNames[columnName] = newValue
    }
    # Print the updated or unchanged line
    print $0
}
' "../data/$currentDatabase/$tableName" > temp_table

mv temp_table "../data/$currentDatabase/$tableName"

echo "Update completed successfully."