#!/usr/bin/bash

if [[ $(ls -A ../data | wc -l) -eq 0 ]]; then
    echo "Directory is empty"
else
    ls -1 ../data
fi

./App/main_menu.sh