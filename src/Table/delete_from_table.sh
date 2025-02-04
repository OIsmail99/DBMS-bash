#!/bin/bash
# DELETE FROM table_name WHERE x(existing column)=y(existing value)
echo hello world
# Read SQL command
#!/bin/bash


read -p "SQL> " sql_cmd


# ^ → Start of the string.
# [[:space:]]* → Allows any leading whitespace (optional).
# DELETE[[:space:]]+FROM → Matches DELETE FROM, allowing spaces between them.
# ([^[:space:];]+) → Captures the table name:
# [^[:space:];]+ → Matches anything except spaces or semicolons (;).
# ([[:space:]]+WHERE[[:space:]]+(.+))? → Optionally captures the WHERE clause:
# (.+) captures the condition after WHERE.
# [[:space:]]*$ → Allows trailing spaces.

# shopt -s nocasematch
# if [[ ! "$sql_cmd" =~ ^[[:space:]]*DELETE[[:space:]]+FROM[[:space:]]+([^[:space:];]+)([[:space:]]+WHERE[[:space:]]+(.+))?[[:space:]]*$ ]]; then
#     echo "Error: Invalid SQL syntax. Use: DELETE FROM table [WHERE condition]"
#     exit 1
# fi
# shopt -u nocasematch  # Turn it off afterward to avoid side effects

if [[ ! "$sql_cmd" =~ ^[[:space:]]*DELETE[[:space:]]+FROM[[:space:]]+([^[:space:];]+)([[:space:]]+WHERE[[:space:]]+(.+))?[[:space:]]*$ ]]; then
    echo "Error: Invalid SQL syntax. Use: DELETE FROM table [WHERE condition]"
    exit 1
fi





table_name=$(sed -E 's/^\s*DELETE\s+FROM\s+([^ ;]+).*/\1/i' <<< "$sql_cmd") #passing the command to sed using here string, then extracting the table name and storing it in table_name, E is to enable extended regex. i is for case insensitive, ^ is for start of the string, \s is for space, + is for one or more, [^ ;] is for anything except space and semicolon, \1 is to store the first group, . is for any character, * is for zero or more.
condition=$(sed -E 's/.*WHERE\s+([^;]+).*/\1/i' <<< "$sql_cmd")


if [[ ! -f "$table_name" ]]; then #-f is for file existence
    echo "Error: Table '$table_name' does not exist"
    exit 1
fi


if [[ ! "$sql_cmd" =~ WHERE ]]; then #if where doesn't exist in the sql command, delete all records
#&& runs the second command only if the first command is successful
#this will extract the first line and store it in a temporary file, then move the temporary file to the original file
    head -n 1 "$table_name" > temp && mv temp "$table_name"
    echo "Deleted all records from '$table_name'"
    exit 0
fi


if [[ "$condition" != *=* ]]; then #if the condition doesn't have an equal sign
    echo "Error: Condition must be in 'column=value' format"
    exit 1
fi

#getting column name and value
IFS='=' read -r col_name value <<< "$condition" #IFS is internal field separator, -r is for raw input, <<< is for here string
col_name=$(tr -d '[:space:]' <<< "$col_name")  #Remove whitespace from column name


value=$(echo "$value" | sed -e "s/^['\"]//" -e "s/['\"]$//")

# Get column index from metadata
metadata=$(head -n 1 "$table_name") #cuz metadata is in the first row
IFS=',' read -ra columns <<< "$metadata" #splitting metadata by comma

col_index=-1
for i in "${!columns[@]}"; do
    IFS=':' read -r name _ <<< "${columns[i]}"
    if [[ "$name" == "$col_name" ]]; then
        col_index=$((i + 1))  # AWK uses 1-based indexing
        break
    fi
done

if [[ $col_index -eq -1 ]]; then
    echo "Error: Column '$col_name' not found"
    exit 1
fi


awk -v col="$col_index" -v val="$value" '
BEGIN { FS=","; OFS="," }
NR == 1 { print; next }  # Keep header
$col != val { print }    # Only print non-matching rows
' "$table_name" > tmpfile && mv tmpfile "$table_name"

echo "Deleted records where $col_name = '$value' from '$table_name'"

src/App/main_menu.sh