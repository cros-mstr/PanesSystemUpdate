#!/bin/bash
cd "$(dirname "$0")"

# Set terminal background color to #00EEFF
printf '\033]11;#0F9096\007'

# Function to draw the desktop
draw_desktop() {
    clear
    # Get terminal size
    local term_rows=$(tput lines)
    local term_cols=$(tput cols)

    # Add a blank line to move the Location bar down
    printf "\n"

    # Location indicator at the top
    printf "\e[1;44m%-*s\e[0m\n" "$term_cols" " Location: Desktop "

    # Calculate space for installed apps
    local app_dir="./Applications"
    local app_counter=10
    local temp_app_list="/tmp/panes_installed_apps_$$_$(date +%s).txt"
    INSTALLED_APPS_GLOBAL=()

    # Collect installed apps
    if [ -d "$app_dir" ]; then
        find "$app_dir" -maxdepth 1 -type f -name "*.sh" | sort > "$temp_app_list"
        while IFS= read -r app_path; do
            local app_filename=$(basename "$app_path")
            local app_display_name="${app_filename%.sh}"
            INSTALLED_APPS_GLOBAL+=("$app_filename")
        done < "$temp_app_list"
    fi
    rm -f "$temp_app_list"

    # Calculate how many lines are needed for installed apps
    local app_lines=${#INSTALLED_APPS_GLOBAL[@]}
    local content_height=$((term_rows - 4)) # 1 for top, 2 for menu, 1 for spacing

    # Print installed apps, filling vertical space
    local i=0
    while ((i < app_lines && i < content_height)); do
        local app_filename="${INSTALLED_APPS_GLOBAL[i]}"
        local app_display_name="${app_filename%.sh}"
        printf "\e[1;35m  [%d] %s\e[0m\n" "$((10+i))" "$app_display_name"
        ((i++))
    done
    # Fill remaining space with blank lines
    while ((i < content_height)); do
        echo
        ((i++))
    done

    # Prepare horizontal menu for the bottom
    local menu_items=(
        "[1] Text Editor" "[2] Calculator" "[3] File Viewer" "[4] Guess Game" \
        "[5] App Store" "[6] Animation" "[7] Check Updates" "[8] Reinstall" "[9] Exit"
    )
    local menu_line=""
    for item in "${menu_items[@]}"; do
        if (( ${#menu_line} + ${#item} + 2 > term_cols )); then
            printf "%s\n" "$menu_line"
            menu_line="$item  "
        else
            menu_line+="$item  "
        fi
    done
    printf "\e[1;44m%-*s\e[0m\n" "$term_cols" "$menu_line"
    # Bottom bar
    printf "\e[1;34m%-*s\e[0m\n" "$term_cols" "────────────────────────────────────────────────────────────────"
    printf "\e[1;36m%-*s\e[0m\n" "$term_cols" "Desktop Ready!"
}

# Function to launch an application
launch_application() {
    local app_full_path="$1"
    clear
    echo "Launching $(basename "$app_full_path" .sh)..."
    sleep 1
    ( bash "$app_full_path" ) # Execute the application in a subshell
    echo -e "\nApplication finished. Press [Enter] to return to the desktop."
    read -r < /dev/tty
}

# Function to handle the Out-Of-Box Experience (OOBE)
run_oobe() {
    clear
    echo "==================================="
    echo "| Welcome to Panes - Initial Setup |"
    echo "==================================="
    echo

    # Prompt for username
    read -r -p "Enter your username: " username
    while [[ -z "$username" ]]; do
        echo "Username cannot be empty. Please try again."
        read -r -p "Enter your username: " username
    done

    # Prompt for language
    echo "Select your language:"
    echo "1) English"
    echo "2) Spanish"
    echo "3) French"
    echo "4) German"
    echo "5) Other"
    read -r -p "Enter the number corresponding to your language: " language_option
    case $language_option in
        1) language="English" ;;
        2) language="Spanish" ;;
        3) language="French" ;;
        4) language="German" ;;
        5) read -r -p "Enter your language: " language ;;
        *) echo "Invalid option. Defaulting to English."; language="English" ;;
    esac

    # Prompt for password
    read -r -p "Would you like to set a password? (y/n): " set_password
    if [[ "$set_password" =~ ^[Yy]$ ]]; then
        read -r -s -p "Enter your password: " password
        echo
        read -r -s -p "Confirm your password: " password_confirm
        echo
        if [[ "$password" != "$password_confirm" ]]; then
            echo "Passwords do not match. Please try again."
            run_oobe
            return
        fi
    else
        password=""
    fi

    # Save user data to UserData file
    echo "USERNAME=$username" > UserData
    echo "LANGUAGE=$language" >> UserData
    if [[ -n "$password" ]]; then
        echo "PASSWORD=$(echo "$password" | sha256sum | awk '{print $1}')" >> UserData
    fi

    echo "Setup complete! Your information has been saved."
    sleep 2
}

# Main script logic
main() {
    # Play the startup animation
    animate_ascii_art

    # Check if the UserData file exists
    if [[ ! -f UserData ]]; then
        # Run OOBE if UserData does not exist
        run_oobe
    fi

    # Log in the user
    login

    # Proceed to the desktop
    while true; do
        draw_desktop
        read -r -p "Enter your choice: " menu_option < /dev/tty

        case $menu_option in
            1)
                echo "Launching Text Editor..."
                sleep 1
                ;;
            2)
                echo "Launching Calculator..."
                sleep 1
                ;;
            3)
                echo "Launching File Viewer..."
                sleep 1
                ;;
            4)
                echo "Launching Guess Game..."
                sleep 1
                ;;
            5)
                echo "Opening App Store..."
                sleep 1
                app_store
                ;;
            6)
                echo "Running Animation..."
                sleep 1
                ;;
            7)
                check_for_updates
                ;;
            8)
                echo "Reinstalling Panes..."
                sleep 1
                ;;
            9)
                echo "Exiting Panes. Goodbye!"
                sleep 1
                exit 0
                ;;
            *)
                echo "Invalid option. Please choose a valid number."
                sleep 1
                ;;
        esac
    done
}

# Start the script
main
