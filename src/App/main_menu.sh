#!/bin/bash
while true; do
    echo "Welcome to the Main Menu"
    echo "Press 1 to navigate, 2 to see the valid SQL syntax, 3 to exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            ./App/sub_menu.sh
            exit 0
            ;;
        2)
            ./App/Manual.sh
            exit 0
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