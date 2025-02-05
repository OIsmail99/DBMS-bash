#!/usr/bin/bash
while true; do
    read -p "SQL> " input

    
    standardInput=$(echo "$input" | sed 's/=/ = /g; s/  */ /g')

   
    firstWord=$(echo "$standardInput" | cut -d" " -f1)
    secondWord=$(echo "$standardInput" | cut -d" " -f2)
    thirdWord=$(echo "$standardInput" | cut -d" " -f3)

    
    if [[ "$firstWord" =~ ^[Ss][Hh][Oo][Ww]$ ]]; then
        if [[ "$secondWord" =~ ^[Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee][Ss]$ ]]; then
            ./Database/list_database.sh
            break
        else
            ./Table/list_table.sh
            break
        fi
        break
    elif [[ "$firstWord" =~ ^[Dd][Rr][Oo][Pp]$ ]]; then
        ./Database/drop_database.sh $thirdWord
        break
    elif [[ "$firstWord" =~ ^[Ss][Ee][Ll][Ee][Cc][Tt]$ ]]; then
        ./Table/select_table.sh $standardInput
        break
    elif [[ "$firstWord" =~ ^[Ii][Nn][Ss][Ee][Rr][Tt]$ ]]; then
        ./Table/insert_into_table.sh $standardInput
        break
    elif [[ "$firstWord" =~ ^[Uu][Pp][Dd][Aa][Tt][Ee]$ ]]; then
        ./Table/update_table.sh
        break
    elif [[ "$firstWord" =~ ^[Dd][Ee][Ll][Ee][Tt][Ee]$ ]]; then
        ./Table/delete_table.sh
        break
    elif [[ "$firstWord" =~ ^[Cc][Rr][Ee][Aa][Tt][Ee]$ ]]; then
        if [[ "$secondWord" =~ ^[Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee]$ ]]; then
            ./Database/create_database.sh $thirdWord
            break
        else
            ./Table/create_table.sh $standardInput
            break
        fi

    elif [[ "$firstWord" =~ ^[Uu][Ss][Ee]$ ]]; then
        if [[ "$secondWord" =~ ^[Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee]$ ]]; then
            ./Database/connect_database.sh $thirdWord
            break
        else
            echo "Error: Invalid SQL syntax. Please try again."
        fi

    else
        echo "Error: Invalid SQL syntax. Please try again."
    fi

    

done


