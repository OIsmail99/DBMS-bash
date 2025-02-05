#! /usr/bin/bash

read -p "Enter a SQL query:   " input
standardInput=$(echo $input|sed 's/[(),]/ & /g; s/  */ /g')
createField=$(echo $standardInput |cut -d" " -f1)
dataBaseField=$(echo $standardInput |cut -d" " -f2)
dataBaseName=$(echo $standardInput |cut -d" " -f3)


if [[  "$standardInput" =~ \)$ ]];then
echo "Error: The query must end with a closing parenthesis"
    exit 1
fi

if [[ $standardInput =~ \).*[^[:space:]] ]]; then
echo "Error: Unexpected characters after closing parenthesis."
exit 1
fi

if [[ $createField =~ ^[Cc][Rr][Ee][Aa][Tt][Ee]$ ]]; then
    if [[ $dataBaseField =~ ^[Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee]$ ]];then
        mkdir ../../data/$dataBaseName
    fi
    
    
fi    
