#!/usr/bin/bash



read -p "Enter a SQL query:   " input
standardInput=$(echo $input|sed 's/[(),]/ & /g; s/  */ /g')

openBracketCount=$(echo ""$standardInput"" | tr -cd "(" | wc -c)
closeBracketCount=$(echo ""$standardInput"" | tr -cd ")" | wc -c)

if [[ $openBracketCount -lt 2 ]]; then
echo "Error: Fewer opening parentheses than expected."
exit 1
fi

if [[ $openBracketCount -gt 2 ]]; then
  echo "Error: More opening parentheses than expected."
  exit 1
fi

if [[ $closeBracketCount -lt 2 ]]; then
echo "Error: Fewer closing parentheses than expected."
exit 1
fi

if [[ "$closeBracketCount" -gt 2 ]]; then
  echo "Error: More closing parentheses than expected."
  exit 1
fi

insertField=$(echo "$standardInput" |cut -d" " -f1)
intoField=$(echo "$standardInput" |cut -d" " -f2)
tableName=$(echo "$standardInput" |cut -d" " -f3)

userColumns=$(echo "$standardInput" | cut -d"(" -f2 |cut -d")" -f1)
userValues=$(echo "$standardInput" | cut -d"(" -f3 |cut -d")" -f1)

metaData="$(head -1 $tableName)"
if [ ! -f "$tableName" ]; then
    echo "ERROR: $tableName table is not found"
    exit 1
fi

userColumns=$(echo "$userColumns" | sed "s/ //g")
userValues=$(echo "$userValues" | sed "s/ //g")


if [[ "$standardInput" =~ \).*[^[:space:]] ]]; then
echo "Error: Unexpected characters after closing parenthesis."
exit 1
fi
if [[ $insertField =~ ^[Ii][Nn][Ss][Ee][Rr][Tt]$ ]]; then
    echo yes Insert
    if [[ $intoField =~ ^[Ii][Nn][Tt][Oo]$ ]];then
        echo yes into
    if [[ ! -e "$tableName" ]]; then #-f is for file existence
    echo "Error: Table '$tableName' does not exist"
    exit 1
    fi
    if [[ ! "$standardInput" =~ \)\ [Vv][Aa][Ll][Uu][Ee][Ss]\ \( ]]; then
    echo  "VALUES Keyword is missing"
    exit 1
    fi
        
      awk -v userColumns="$userColumns" -v userValues="$userValues" -v metaData="$metaData" -v tableName="$tableName" ' 
        BEGIN {
        line=""
        primaryMeta=""
        primaryValue=""
        userColumnsCount= split(userColumns,userColumnsArray,",")
        userValuesCount=split(userValues,userValuesArray,",")
        metaDataCount=split(metaData,metaDataArray,",")
        
        
       if (userColumnsCount!=userValuesCount){
       print "Error: Number of columns and values do not match"
       exit 1
       }
         for(i=1;i<=userColumnsCount;i++){
         for(j=1;j<=metaDataCount; j++){ 
       
        split(metaDataArray[j],columnMetaData,":")
         if( columnMetaData[1]==userColumnsArray[i]){
         if(columnMetaData[3]=="PK"){
         primaryMeta=columnMetaData[1]
         primaryValue=userValuesArray[i]
         PrimaryKeyLocation= j
         }
       
            if(columnMetaData[2] == "BOOLEAN"){
            if(tolower(userValuesArray[i]) ~ /^(true|false)$/){
            record[userColumnsArray[i]]= tolower(userValuesArray[i])
            }
            else{
             print "ERROR: Expected BOOLEAN but got : " userValuesArray[i]
             exit 1
            }
            }

            if(columnMetaData[2] == "INT"){
            if(userValuesArray[i] ~ /^[0-9]+$/){
            record[userColumnsArray[i]]= userValuesArray[i]
            }
            else{
             print "ERROR: Expected INT but got : " userValuesArray[i]
             exit 1
            }
            }

            if(columnMetaData[2] == "STRING"){
            if(userValuesArray[i] !~ /^[Nn][Uu][Ll][Ll]$/){
            record[userColumnsArray[i]]= userValuesArray[i]
            }
            else{
             print "ERROR: Invalid input. Expected a non-null value"
             exit 1
            }
            }
    
            break
         }
        }
        }
        metaLineSkip=1
        while((getline currLine < tableName)>0){
        if(metaLineSkip){
        metaLineSkip=0
        continue;
        }
        split(currLine,currData,":")
      
        if(currData[PrimaryKeyLocation]==primaryValue){
        print "ERROR: Primary key violation." primaryValue  " is already in the database"  
                    exit 1
        
        }
        }
        
        for (i=1;i<=metaDataCount; i++){
        split(metaDataArray[i],columnMetaData,":")
        if(record[columnMetaData[1]]!=""){
       line=line  record[columnMetaData[1]] ":"

        }
        else {
      
               line=line "NULL:"

        }
        
        }
         if (line !="")
        {
        print substr(line,1,length(line)-1)
        }
         
       
   }
   ' >> $tableName
          if [[ ! -s $tableName ]];then
        rm -f $tableName
        fi
fi        
    fi    