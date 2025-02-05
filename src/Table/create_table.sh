#! /usr/bin/bash

#validate table name

read -p "Enter a SQL query:   " input
standardInput=$(echo $input|sed 's/[(),]/ & /g; s/  */ /g')
createField=$(echo $standardInput |cut -d" " -f1)
tableField=$(echo $standardInput |cut -d" " -f2)
tableName=$(echo $standardInput |cut -d" " -f3)
columns=$(echo $standardInput | sed 's/.*(//;s/).*//')


if [[  "$standardInput" =~ \)$ ]];then
echo "Error: The query must end with a closing parenthesis"
    exit 1
fi

if [[ $standardInput =~ \).*[^[:space:]] ]]; then
echo "Error: Unexpected characters after closing parenthesis."
exit 1
fi


if [[ $createField =~ ^[Cc][Rr][Ee][Aa][Tt][Ee]$ ]]; then
    if [[ $tableField =~ ^[Tt][Aa][Bb][Ll][Ee]$ ]];then
       echo $columns | awk -F' , ' '

       BEGIN {
       pkStatus=0
        line=""
       }

        {
        for (i=1;i<=NF;i++){
        column=$i

        split(column,items," ")
        columnName=items[1]
        dataType = toupper(items[2])
        primaryKeyConstraint=items[3] " " items[4]

        if (dataType != "INT" && dataType != "STRING"  && dataType != "BOOLEAN" ){
        print "Error: Invalid data type " dataType > "/dev/stderr"
        exit 1
        }
        
        if(primaryKeyConstraint ~ /^[Pp][Rr][Ii][Mm][Aa][Rr][Yy][[:space:]]+[Kk][Ee][Yy]$/ && pkStatus == 0){
        pkStatus=1
        line = line columnName ":" dataType ":PK,"
        } 
       else if(primaryKeyConstraint ~ /^[Pp][Rr][Ii][Mm][Aa][Rr][Yy][[:space:]]+[Kk][Ee][Yy]$/){
       line=""
       break
        }
        else if (i!=NF){
        line = line columnName ":" dataType  ","
        }
        else{
        line = line columnName ":" dataType
        }
        }
        }

        END{
        if(line!="")print substr(line,1,length(line)-1)
        }'>$tableName
        
        if [[ ! -s $tableName ]];then
        rm -f $tableName
        fi
    fi
fi



