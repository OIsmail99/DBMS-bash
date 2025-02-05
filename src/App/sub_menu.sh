#!/usr/bin/bash
while true; do
    read -p "SQL> " input

    
    standardInput=$(echo "$input" | sed 's/=/ = /g; s/  */ /g')

   
    firstWord=$(echo "$standardInput" | cut -d" " -f1)
    secondWord=$(echo "$standardInput" | cut -d" " -f2)

    
    if [[ "$firstWord" =~ ^[Ss][Hh][Oo][Ww]$ ]]; then
        if [[ "$secondWord" =~ ^[Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee][Ss]$ ]]; then
            /src/Database/list_database.sh
            break
        else
            /src/Table/list_table.sh
            break
        fi
        break
    elif [[ "$firstWord" =~ ^[Dd][Rr][Oo][Pp]$ ]]; then
        /src/Database/drop_database.sh
        break
    elif [[ "$firstWord" =~ ^[Ss][Ee][Ll][Ee][Cc][Tt]$ ]]; then
        /src/Table/select_table.sh
        break
    elif [[ "$firstWord" =~ ^[Ii][Nn][Ss][Ee][Rr][Tt]$ ]]; then
        /src/Table/insert_table.sh
        break
    elif [[ "$firstWord" =~ ^[Uu][Pp][Dd][Aa][Tt][Ee]$ ]]; then
        /src/Table/update_table.sh
        break
    elif [[ "$firstWord" =~ ^[Dd][Ee][Ll][Ee][Tt][Ee]$ ]]; then
        /src/Table/delete_table.sh
        break
    elif [[ "$firstWord" =~ ^[Cc][Rr][Ee][Aa][Tt][Ee]$ ]]; then
        if [[ "$secondWord" =~ ^[Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee]$ ]]; then
            /src/Database/create_database.sh
            break
        else
            /src/Table/create_table.sh
            break
        fi
    else
        echo "Error: Invalid SQL syntax. Please try again."
    fi
done


