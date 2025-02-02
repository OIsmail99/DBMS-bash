#!/bin/bash
# validate sql syntax to be (SELECT * FROM table_name) .. anything else will be rejected
# read the sql command
read -p "SQL> " sql_cmd
# validate the sql syntax
if [[ ! "$sql_cmd" =~ ^[[:space:]]*SELECT[[:space:]]+\*[[:space:]]+FROM[[:space:]]+([^[:space:];]+)[[:space:]]*$ ]]; then
    echo "Error: Invalid SQL syntax. Use: SELECT * FROM table"
    exit 1
fi

table_name=$(sed -E 's/^\s*SELECT\s+\*\s+FROM\s+([^ ;]+).*/\1/i' <<< "$sql_cmd")

if [[ ! -f "$table_name" ]]; then
    echo "Error: Table '$table_name' does not exist"
    exit 1
fi

tail -n +2 "$table_name"
# +2 is to start from the second line, so it will skip the header