#!/usr/bin/bash
echo "Valid SQL syntax (Anything else will be invalid):"
echo "To create a table: CREATE TABLE table_name (column1_name column1_type, column2_name column2_type, ...)"
echo "To insert into a table: INSERT INTO table_name VALUES (value1, value2, ...)"
echo "To update a table: UPDATE table_name SET column1_name = value1 WHERE CONDITION .. ONLY ONE UPDATE AT A TIME IS ALLOWED"
echo "To select from a table: SELECT * FROM table_name"
echo "To delete from a table: DELETE FROM table_name WHERE condition"
echo "To delete all the data from a table: DELETE FROM table_name"
echo "To drop a table: DROP TABLE table_name"
echo "To drop a database: DROP DATABASE database_name"
echo "to show the tables: SHOW TABLES"

read -p "Press 1 to go back to the main menu: " choice
while [ $choice -ne 1 ]; do
    read -p "Invalid choice. Press 1 to go back to the main menu: " choice
done
src/App/main_menu.sh
