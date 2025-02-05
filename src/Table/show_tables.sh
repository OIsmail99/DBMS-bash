#!/usr/bin/bash

read -p "Enter a SQL query:   " input
standardInput=$(echo $input|sed 's/[(),]/ & /g; s/  */ /g')

showField=$(echo $standardInput |cut -d" " -f1)
tableField=$(echo $standardInput |cut -d" " -f2)

if [[ ! "$showField" =~ ^[Ss][Hh][Oo][Ww]$ ]]; then
    echo "Error: Invalid Syntax."
    exit 1
fi

if [[ ! "$tableField" =~ ^[Tt][Aa][Bb][Ll][Ee][Ss]$ ]]; then
    echo "Error: Invalid Syntax."
    exit 1
fi


ls -1 /data/$1