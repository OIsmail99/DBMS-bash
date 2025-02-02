#!/bin/bash
#validate drop table command (DROP table_name)
#read the sql command
read -p "SQL> " sql_cmd
#validate the sql syntax
if [[ ! "$sql_cmd" =~ ^[[:space:]]*DROP[[:space:]]+TABLE[[:space:]]+([^[:space:];]+)[[:space:]]*$ ]]; then
    echo "Error: Invalid SQL syntax. Use: DROP TABLE table"
    exit 1
fi

table_name=$(sed -E 's/^\s*DROP\s+TABLE\s+([^ ;]+).*/\1/i' <<< "$sql_cmd")


if [[ ! -f "$table_name" ]]; then
    echo "Error: Table '$table_name' does not exist"
    exit 1
fi

rm -rf "$table_name"
echo "Table '$table_name' dropped successfully"
exit 0