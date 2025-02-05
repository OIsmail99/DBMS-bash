#!/usr/bin/bash

# Function to display error messages and exit
error_exit() {
    echo "Error: $1"
    exit 1
}

# Read the current database name
currentDatabase=$(cat ../data/current_database.txt 2>/dev/null)

# Validate if a database is selected
if [[ ! -f "../data/current_database.txt" ]]; then
    error_exit "No database selected."
fi

# Read the SQL query from arguments
input=$*
echo "Input: $input"

# Tokenize the input by adding spaces around parentheses and commas
standardInput=$(echo "$input" | sed 's/[=]/ & /g; s/  */ /g')

# Parse the SQL query
fromField=$(echo "$standardInput" | cut -d" " -f2)
tableName=$(echo "$standardInput" | cut -d" " -f3)
condition=$(echo "$standardInput" | grep -oP '(?<=WHERE\s).+')

# Validate DELETE FROM command
if [[ $deleteField =~ ^[Dd][Ee][Ll][Ee][Tt][Ee]$ ]]; then
    if [[ $fromField =~ ^[Ff][Rr][Oo][Mm]$ ]]; then
        # Validate table existence
        if [[ ! -f "../data/$currentDatabase/$tableName" ]]; then
            error_exit "Table '$tableName' does not exist."
        fi

        # Validate condition format
        if [[ -z "$condition" ]]; then
            error_exit "Condition is missing. Use: DELETE FROM tableName WHERE X=Y"
        fi

        # Extract column name and value from the condition
        if [[ "$condition" != *=* ]]; then
            error_exit "Condition must be in 'column=value' format."
        fi

        IFS='=' read -r col_name value <<< "$condition"
        col_name=$(tr -d '[:space:]' <<< "$col_name")  # Remove whitespace from column name
        value=$(echo "$value" | sed -e "s/^['\"]//" -e "s/['\"]$//")  # Remove quotes

        # Read metadata from the table file
        metaData=$(head -1 "../data/$currentDatabase/$tableName")

        # Get column index from metadata
        IFS=',' read -ra columns <<< "$metaData"

        col_index=-1
        for i in "${!columns[@]}"; do
            IFS=':' read -r name _ <<< "${columns[i]}"
            if [[ "$name" == "$col_name" ]]; then
                col_index=$((i + 1))  # AWK uses 1-based indexing
                break
            fi
        done

        if [[ $col_index -eq -1 ]]; then
            error_exit "Column '$col_name' not found."
        fi

        # Use AWK to filter and delete rows
        awk -v col="$col_index" -v val="$value" '
        BEGIN { FS=":"; OFS=":" }
        NR == 1 { print; next }  # Keep header
        $col != val { print }    # Only print non-matching rows
        ' "../data/$currentDatabase/$tableName" > tmpfile && mv tmpfile "../data/$currentDatabase/$tableName"

        echo "Deleted records where $col_name = '$value' from '$tableName'."
    else
        error_exit "Invalid command. Expected 'FROM'."
    fi
else
    error_exit "Invalid command. Expected 'DELETE'."
fi

# Return to the submenu
./App/sub_menu.sh