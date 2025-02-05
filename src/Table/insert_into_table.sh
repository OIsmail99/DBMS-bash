#!/usr/bin/bash

# Read the current database name
currentDatabase=$(cat ../data/current_database.txt 2>/dev/null)

input=$*
echo $input
# Validate if a database is selected
if [[ ! -f "../data/current_database.txt" ]]; then
    echo "Error: No database selected."
    exit 1
fi

# Prompt the user for an SQL query
standardInput=$(echo "$input" | sed 's/[(),]/ & /g; s/  */ /g')

# Count the number of opening and closing parentheses
openBracketCount=$(echo "$standardInput" | tr -cd "(" | wc -c)
closeBracketCount=$(echo "$standardInput" | tr -cd ")" | wc -c)

# Validate parentheses count
if [[ $openBracketCount -ne 2 ]]; then
    echo "Error: Expected exactly 2 opening parentheses."
    exit 1
fi

if [[ $closeBracketCount -ne 2 ]]; then
    echo "Error: Expected exactly 2 closing parentheses."
    exit 1
fi

# Parse the SQL query
insertField=$(echo "$standardInput" | cut -d" " -f1)
intoField=$(echo "$standardInput" | cut -d" " -f2)
tableName=$(echo "$standardInput" | cut -d" " -f3)

userColumns=$(echo "$standardInput" | cut -d"(" -f2 | cut -d")" -f1)
userValues=$(echo "$standardInput" | cut -d"(" -f3 | cut -d")" -f1)

# Validate table existence
if [[ ! -f "../data/$currentDatabase/$tableName" ]]; then
    echo "Error: Table '$tableName' does not exist."
    exit 1
fi

# Read metadata from the table file
metaData=$(head -1 "../data/$currentDatabase/$tableName")

# Remove spaces from user input
userColumns=$(echo "$userColumns" | sed "s/ //g")
userValues=$(echo "$userValues" | sed "s/ //g")

# Validate INSERT INTO command
if [[ $insertField =~ ^[Ii][Nn][Ss][Ee][Rr][Tt]$ ]]; then
    if [[ $intoField =~ ^[Ii][Nn][Tt][Oo]$ ]]; then
        # Validate VALUES keyword
        if [[ ! "$standardInput" =~ \)\ [Vv][Aa][Ll][Uu][Ee][Ss]\ \( ]]; then
            echo "Error: 'VALUES' keyword is missing."
            exit 1
        fi

        # Use awk to process and validate the input
        awk -v userColumns="$userColumns" -v userValues="$userValues" -v metaData="$metaData" -v tableName="../data/$currentDatabase/$tableName" '
        BEGIN {
            line = ""
            primaryMeta = ""
            primaryValue = ""
            userColumnsCount = split(userColumns, userColumnsArray, ",")
            userValuesCount = split(userValues, userValuesArray, ",")
            metaDataCount = split(metaData, metaDataArray, ",")

            # Check if the number of columns and values match
            if (userColumnsCount != userValuesCount) {
                print "Error: Number of columns and values do not match." > "/dev/stderr"
                exit 1
            }

            # Map user columns to metadata and validate data types
            for (i = 1; i <= userColumnsCount; i++) {
                for (j = 1; j <= metaDataCount; j++) {
                    split(metaDataArray[j], columnMetaData, ":")
                    if (columnMetaData[1] == userColumnsArray[i]) {
                        if (columnMetaData[3] == "PK") {
                            primaryMeta = columnMetaData[1]
                            primaryValue = userValuesArray[i]
                            PrimaryKeyLocation = j
                        }

                        # Validate data types
                        if (columnMetaData[2] == "BOOLEAN") {
                            if (tolower(userValuesArray[i]) ~ /^(true|false)$/) {
                                record[userColumnsArray[i]] = tolower(userValuesArray[i])
                            } else {
                                print "Error: Expected BOOLEAN but got: " userValuesArray[i] > "/dev/stderr"
                                exit 1
                            }
                        }

                        if (columnMetaData[2] == "INT") {
                            if (userValuesArray[i] ~ /^[0-9]+$/) {
                                record[userColumnsArray[i]] = userValuesArray[i]
                            } else {
                                print "Error: Expected INT but got: " userValuesArray[i] > "/dev/stderr"
                                exit 1
                            }
                        }

                        if (columnMetaData[2] == "STRING") {
                            if (userValuesArray[i] !~ /^[Nn][Uu][Ll][Ll]$/) {
                                record[userColumnsArray[i]] = userValuesArray[i]
                            } else {
                                print "Error: Invalid input. Expected a non-null value." > "/dev/stderr"
                                exit 1
                            }
                        }

                        break
                    }
                }
            }

            # Check for primary key violation
            metaLineSkip = 1
            while ((getline currLine < tableName) > 0) {
                if (metaLineSkip) {
                    metaLineSkip = 0
                    continue
                }
                split(currLine, currData, ":")
                if (currData[PrimaryKeyLocation] == primaryValue) {
                    print "Error: Primary key violation. " primaryValue " is already in the database." > "/dev/stderr"
                    exit 1
                }
            }

            # Construct the new record
            for (i = 1; i <= metaDataCount; i++) {
                split(metaDataArray[i], columnMetaData, ":")
                if (record[columnMetaData[1]] != "") {
                    line = line record[columnMetaData[1]] ":"
                } else {
                    line = line "NULL:"
                }
            }

            # Print the new record (remove trailing colon)
            if (line != "") {
                print substr(line, 1, length(line) - 1)
            }
        }
        ' >> "../data/$currentDatabase/$tableName"

        # Check if the file was updated successfully
        if [[ ! -s "../data/$currentDatabase/$tableName" ]]; then
            rm -f "../data/$currentDatabase/$tableName"
            echo "Error: Failed to insert data into table '$tableName'."
            exit 1
        else
            echo "Data inserted successfully into table '$tableName'."
        fi
    else
        echo "Error: Invalid command. Expected 'INTO'."
        exit 1
    fi
else
    echo "Error: Invalid command. Expected 'INSERT'."
    exit 1
fi

./App/sub_menu.sh