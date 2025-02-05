#! /usr/bin/bash

    if [[ -d ../data/$1 ]]; then
        cd ../data/$1
        echo "Database $1 selected"
        echo $PWD
        touch ../current_database.txt
        echo $1 > ../current_database.txt
    else
        echo "Error: Database $1 does not exist."
    fi

cd ../../src
./App/sub_menu.sh
 
