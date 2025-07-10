#!/bin/bash

# Color and formatting variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Animation speed (floating number)
TOTAL_ANIMATION_DURATION=$(echo "scale=4; 1/12" | bc -l) # ~0.0833 sec (80ms)
CLEAR_SCREEN="clear"

# Export terminal settings globally
export LC_ALL=C

title_ascii_art=$(cat << "EOF"
██████╗  █████╗ ██████╗ ██╗         ██████╗  ██████╗ ██████╗ ███████╗██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗██║         ██╔══██╗██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║ ██╔╝
██████╔╝███████║██║  ██║██║         ██████╔╝██║   ██║██████╔╝█████╗  ██████╔╝█████╔╝
██╔═══╝ ██╔══██║██║  ██║██║         ██╔═══╝ ██║   ██║██╔══██╗██╔══╝  ██╔═══╝ ██╔═██╗
██║     ██║  ██║██████╔╝███████╗    ██║     ╚██████╔╝██║  ██║███████╗██║     ██║  ██╗
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚══════╝    ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝
EOF
)

# Function to animate ASCII art by fading in lines
animate_ascii_art() {
    local art="$1"
    local total_lines
    local delay

    # Count lines and calculate delay per line to fit total animation duration
    total_lines=$(echo "$art" | wc -l)
    if [[ $total_lines -gt 0 ]]; then
        delay=$(echo "scale=4; $TOTAL_ANIMATION_DURATION / $total_lines" | bc -l)
    else
        delay=0.05
    fi

    # Clear screen first
    $CLEAR_SCREEN
    local i=0
    while IFS= read -r line; do
        printf "%s%s\n" "$BOLD$BLUE" "$line"
        sleep "$delay"
    done <<< "$art"
    printf "%s" "$RESET"
}

# Placeholder for existing functions
text_editor() {
    echo "Text Editor functionality goes here."
    echo "Press [Enter] to return to the desktop."
    read -r < /dev/tty
}

calculator() {
    echo "Calculator functionality goes here."
    echo "Press [Enter] to return to the desktop."
    read -r < /dev/tty
}

file_viewer() {
    echo "File Viewer functionality goes here."
    echo "Press [Enter] to return to the desktop."
    read -r < /dev/tty
}

guessing_game() {
    echo "Guessing Game functionality goes here."
    echo "Press [Enter] to return to the desktop."
    read -r < /dev/tty
}

app_store() {
    while true; do
        echo -e "\n${GREEN}App Store Menu${RESET}"
        local options=("Search by Category" "View App List" "Recommended Apps" "Exit")
        select opt in "${options[@]}"; do
            case "$REPLY" in
                1) echo "You chose to Search by Category"; break ;;
                2) echo "Viewing App List"; break ;;
                3) echo "Showing Recommended Apps"; break ;;
                4) echo "Exiting App Store..."; return ;;
                *) echo "Invalid option. Try again." ;;
            esac
        done < /dev/tty
    done
}

shooting_star() {
    echo "Shooting star animation placeholder."
    echo "Press [Enter] to return."
    read -r < /dev/tty
}

draw_ascii_art() {
    echo "Draw ASCII Art placeholder."
    echo "Press [Enter] to return."
    read -r < /dev/tty
}

check_for_updates() {
    echo "Check for updates placeholder."
    echo "Press [Enter] to return."
    read -r < /dev/tty
}

ReInstall() {
    echo "ReInstall functionality placeholder."
    echo "Press [Enter] to return."
    read -r < /dev/tty
}

# === New installer feature as requested ===
installer_menu() {
    clear
    local installer_dir="$(dirname "$0")/ToBeInstalled"
    echo "==================================="
    echo "|       Panes Installer Menu      |"
    echo "==================================="

    # Check if ToBeInstalled directory exists
    if [[ ! -d "$installer_dir" ]]; then
        echo "The ToBeInstalled directory does not exist at:"
        echo "  $installer_dir"
        echo "Creating the directory now..."
        mkdir -p "$installer_dir"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to create $installer_dir. Check permissions."
            echo "Press [Enter] to return to main menu."
            read -r < /dev/tty
            return
        fi
        echo "Directory created."
        echo "Please add your installer bash scripts (*.sh) to this directory."
        echo "Press [Enter] to return to main menu."
        read -r < /dev/tty
        return
    fi

    # Check for bash scripts inside ToBeInstalled
    mapfile -t installers < <(find "$installer_dir" -maxdepth 1 -type f -name "*.sh" | sort)

    if [[ ${#installers[@]} -eq 0 ]]; then
        echo "No installer scripts (*.sh) found in $installer_dir."
        echo "Add your installation scripts here and restart the installer."
        echo "Press [Enter] to return to main menu."
        read -r < /dev/tty
        return
    fi

    # Prepare table header
    printf "%-3s | %-25s | %-10s\n" "No." "Script Name" "Version"
    printf -- "---------------------------------------------\n"

    # Read VERSION variable from each script safely
    local i=1
    local installers_names=()
    for script_path in "${installers[@]}"; do
        local script_name
        script_name=$(basename "$script_path")
        local version
        # Extract VERSION variable: only the first match, avoid code execution by parsing safe
        version=$(grep -m1 -E '^VERSION=' "$script_path" | cut -d= -f2- | tr -d '"\' ')

        if [[ -z "$version" ]]; then
            version="N/A"
        fi
        printf "%-3d | %-25s | %-10s\n" "$i" "$script_name" "$version"
        installers_names+=("$script_name")
        ((i++))
    done

    echo
    echo "Select an installer to run, or 0 to return:"
    while true; do
        read -r -p "Enter choice [0-${#installers_names[@]}]: " choice < /dev/tty
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 0 && choice <= ${#installers_names[@]} )); then
            if (( choice == 0 )); then
                # Go back to main menu
                return
            fi
            # Run the selected installer script
            local selected_script="${installer_dir}/${installers_names[choice-1]}"
            echo "Running installer: $selected_script"
            if [[ -x "$selected_script" ]]; then
                bash "$selected_script"
            else
                echo "Script is not executable, adding execute permission."
                chmod +x "$selected_script"
                bash "$selected_script"
            fi
            echo "Installer finished. Press [Enter] to return to Installer Menu."
            read -r < /dev/tty
            installer_menu # Show installer menu again after one runs
            return
        else
            echo "Invalid choice. Please enter a number 0 to ${#installers_names[@]}."
        fi
    done
}

# Main menu function with all options
main_menu() {
    while true; do
        echo -e "\n${GREEN}Main Menu:${RESET}"
        local choices=(
            "Open Text Editor"
            "Calculator"
            "File Viewer"
            "Guessing Game"
            "App Store"
            "Shooting Star"
            "Draw ASCII Art"
            "Check for Updates"
            "ReInstall"
            "Installer"
            "Quit"
        )
        PS3="Choose an option: "
        select choice in "${choices[@]}"; do
            case "$REPLY" in
                1)
                    text_editor
                    break
                    ;;
                2)
                    calculator
                    break
                    ;;
                3)
                    file_viewer
                    break
                    ;;
                4)
                    guessing_game
                    break
                    ;;
                5)
                    app_store
                    break
                    ;;
                6)
                    shooting_star
                    break
                    ;;
                7)
                    draw_ascii_art
                    break
                    ;;
                8)
                    check_for_updates
                    break
                    ;;
                9)
                    ReInstall
                    break
                    ;;
                10)
                    installer_menu
                    break
                    ;;
                11)
                    clear
                    echo "Exiting Panes..."
                    sleep 1
                    exit 0
                    ;;
                *)
                    echo "Invalid selection."
                    ;;
            esac
        done < /dev/tty
    done
}

# Main script execution:
animate_ascii_art "$title_ascii_art"
main_menu
