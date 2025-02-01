#!/bin/bash
while true; do
    
    echo "Press 1 to navigate, 2 to see the valid SQL syntax, 3 to exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            src/App/sub_menu.sh
            ;;
        2)
            src/App/Manual.sh
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, or 3."
            ;;
    esac
done