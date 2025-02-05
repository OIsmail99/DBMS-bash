#!/usr/bin/bash
    databaseName=$1


    if [ ! -d "../data/$databaseName" ]; then
        echo "Error: Database '$databaseName' does not exist"
       

    else
    rm -r "../data/$databaseName"
    echo "Database '$databaseName' dropped successfully."
   
    fi
./App/main_menu.sh