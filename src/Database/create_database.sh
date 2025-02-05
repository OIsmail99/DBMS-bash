#! /usr/bin/bash

if [[ ! $1 =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    echo "Invalid database name"
    ./App/sub_menu.sh
fi

cd ../data
if [[  -d $1  ]]; then
    echo "Database already exists"
    cd ../src
    ./App/sub_menu.sh
else
    cd ../src
    mkdir ../data/$1
    echo "Database created successfully"
    ./App/sub_menu.sh
fi

