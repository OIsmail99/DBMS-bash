#! /usr/bin/bash
#why does $1 not written in curret_database.txt

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
 
# if [[ -d ../data/$1 ]]; then
#     cd ../data/$1
#     echo "Database $1 selected"
#     echo $PWD
#     cd ../../src
#     ../../App/sub_menu.sh
# else
#     echo "Error: Database $1 does not exist."
#     cd ../../src
#     ./App/sub_menu.sh
# fi


#at src/ again
