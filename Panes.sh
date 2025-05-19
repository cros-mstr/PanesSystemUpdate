#!/bin/bash
cd "$(dirname "$0")"

# Check if the script is running from a specific path
PARENT_DIR=$(dirname "$(pwd)")
INSTALLED_DIR="$PARENT_DIR/Installed"

VERSION=1.02
# Duration for initial animation in seconds
TOTAL_ANIMATION_DURATION=1/5
SPINNER_DELAY=0.25
TOTAL_UPDATE_DURATION=1/3

# Function to draw the desktop
draw_desktop() {
    clear
    echo "============================="
    echo "|            Panes          |"
    echo "|---------------------------|"
    echo "|  [1] Text Editor          |"
    echo "|  [2] Calculator           |"
    echo "|  [3] File Viewer          |"
    echo "|  [4] Guessing Game        |"
    echo "|  [5] Animation            |"
    echo "|  [6] Check for Updates    |"
    echo "|  [7] Reinstall Panes    |"
    echo "|  [8] Exit                 |"
    echo "============================="
    echo "Desktop"
    echo "============================="
}

# Function to add a shooting star animation
shooting_star() {
    local star_count=50
    for ((i=0; i<star_count; i++)); do
        local star_position=$((RANDOM % 80))
        tput cup $((RANDOM % 20)) $star_position
        echo -n "*"
        sleep 0.000001
        tput cup $((RANDOM % 20)) $star_position
        echo -n " "
    done
}

# Initial Boot Animation
shooting_star
animate_ascii_art() {
    local letters=("P" "A" "N" "E" "S")
    local patterns=(
        "   ****     *****     **   *     *****  *********************************"
        "   *  *    **   **    * *  *     *     *           *    *     *"
        "   ****    *******    *  * *     ****   *****      *    *      *******"
        "   *       **   **    *   **     *           *     *    *             *"
        "   ******************************************     *******      *******"
    )

    local delay=$(echo "$TOTAL_ANIMATION_DURATION / 20" | bc -l) # Calculate delay for the animation
    local rows=${#patterns[@]} # Number of rows to animate

    clear
    for ((step=1; step<=${#patterns[0]}; step++)); do
        for ((row=0; row<rows; row++)); do
            tput cup $row 5 # Move cursor to the starting position for each row
            echo -n "${patterns[row]:0:step}" # Print the already filled characters of each row
        done
        sleep $delay
        clear
    done
    # Give some time to see the fully drawn letters
    sleep 1
}

# Function for the spinner animation
spinner() {
    local spinner_chars=("\\" "|" "/" "-" "-" "/" "|" "\\")
    local brightness=(1 2 3 4 5 6 7) # Brightness levels
    local colors=(33 32 34 35 36 31 37 0) # ANSI color codes (yellow, green, blue, magenta, cyan, red, white)

    local positions=(0 1 2 3) # Indices to handle spinner position adjustment
    local bright_rounds=(0 0 0 0 0 0 0 0) # To track completion of brightness dimming for each character

    while true; do
        for ((i = 0; i < 8; i++)); do
            tput cup 10 30 # Move to spinner position
            for ((j = 0; j < 8; j++)); do
                if [ "$j" -eq "$i" ]; then
                    echo -e "\e[${colors[bright_rounds[j]]}m${spinner_chars[j]}\e[0m"
                else
                    echo -e "\e[0m${spinner_chars[j]}"
                fi
            done

            sleep $SPINNER_DELAY
            
            # Handle dimming logic
            if (( bright_rounds[i] < ${#brightness[@]} - 1 )); then
                ((bright_rounds[i]++)) # Increase brightness level
            else
                bright_rounds[i]=0 # Reset brightness if it has cycled through fully
            fi
        done
    done
}

# Function for recovery actions
recovery() {
    echo -e "\e[41;37m" # Set background color to dark red
    clear
    echo "Panes has suffered an irrecoverable error."
    echo "Please run the setup again."
    sleep 3

    # Clean up: delete the currently running script and the Installed directory
    rm -f "$0" # Remove the running script
    if [ -d "$INSTALLED_DIR" ]; then
        rm -rf "$INSTALLED_DIR" # Remove Installed directory if it exists
    fi

    tput reset # Reset terminal
    exit 1
}

# Function to check for updates
# I had it duped by accident this whole time... whoops...
# Function to check for updates
check_for_updates() {
    clear
    echo "============================="
    echo "|     Check for Updates     |"
    echo "============================="
    echo "Checking for updates..."
    sleep 1
    echo "Available update options:"
    echo "1. Regular update (stable version)"
    echo "2. Dev Seeding (potentially unstable, latest features)"
    read -p "Select an update type (1 or 2): " update_choice

    case "$update_choice" in
        1)
            # Displaying a progress bar
            local total_steps=20 # Total number of steps to display progress
            local step_duration=$(echo "$TOTAL_UPDATE_DURATION * 10 / $total_steps" | bc -l) # Duration of each step
            for ((i=0; i<=total_steps; i++)); do
                sleep "$step_duration"
                printf "\rProgress: ["
                for ((j=0; j<i; j++)); do
                    printf "#"
                done
                for ((j=i; j<total_steps; j++)); do
                    printf " "
                done
                printf "] %d%%" "$((i * 100 / total_steps))"
            done

            echo -e "\n\nUpdate downloaded. Applying changes..."

            # Change directory back up one level and copy the script
            cd $PARENT_DIR
    		cp -f Panes.sh BootFolder/Panes.sh

            echo "Update applied successfully!"
            echo "Press [Enter] to return to the desktop."
            read -r
            ;;
        2)
            echo "Performing Dev Seeding update..."
            # Displaying a progress bar
            local total_steps=20 # Total number of steps to display progress
            local step_duration=$(echo "$TOTAL_UPDATE_DURATION * 10 / $total_steps" | bc -l) # Duration of each step
            for ((i=0; i<=total_steps; i++)); do
                sleep "$step_duration"
                printf "\rProgress: ["
                for ((j=0; j<i; j++)); do
                    printf "#"
                done
                for ((j=i; j<total_steps; j++)); do
                    printf " "
                done
                printf "] %d%%" "$((i * 100 / total_steps))"
            done

            echo -e "\n\nUpdate downloaded. Applying changes..."

            # Change directory back up one level and execute other scripts
            cd $PARENT_DIR
            sudo bash Functions/EnvironmentUpdater.sh
            #ls
            #No more debugging!
            sleep 20
            sudo bash DevSeed.panes/Upgrader.sh
            sleep 10
            ;;
        *)
            echo "Invalid choice. Update cancelled."
            ;;
    esac
}

ReInstall() {
    clear
    echo "============================="
    echo "|       Reinstall PANES     |"
    echo "============================="
    echo "Panes Restore: Grappling Latest PANES"
    sleep 1
    echo "Panes Restore: Prepping for restoration. Downloading..."

    # Displaying a progress bar
    local total_steps=20 # Total number of steps to display progress
    local step_duration=$(( TOTAL_UPDATE_DURATION * 10 / total_steps )) # Duration of each step
    for ((i=0; i<=total_steps; i++)); do
        sleep $step_duration
        printf "\rProgress: ["
        for ((j=0; j<i; j++)); do
            printf "#"
        done
        for ((j=i; j<total_steps; j++)); do
            printf " "
        done
        printf "] %d%%" $((i * 100 / total_steps))
    done

    echo -e "\n\Restore downloaded. Applying changes..."
    
    # Change directory back up one level and copy the script (adjust the path to your BootFolder)
    cd $PARENT_DIR
    sudo rm -rf BootFolder/Panes.sh
    cp -f Panes.sh BootFolder/Panes.sh
    
    echo "Restore applied successfully!"
    echo "Please restart, if the restore failed, the Installation Utility will automatically re-install Panes."
    read -r
}

# Initial animations when the script is first run
shooting_star & # Run shooting star animation in background
spinner_pid=0

# Start spinner in the background
#spinner & spinner_pid=$!
#caused too many issues, no spinner
# Wait and check if the animation completes in 10 seconds
(animate_ascii_art &)
ANIMATION_PID=$!

# Wait for the animation to finish or timeout after 10 seconds
( sleep 10; kill -TERM $ANIMATION_PID 2>/dev/null ) &

# Wait for the animation process
wait $ANIMATION_PID
if [ $? -ne 0 ]; then
    kill $spinner_pid 2>/dev/null  # Stop the spinner
    recovery # Call recovery if the animation did not finish successfully
fi
#deprecated spinner
#wait $spinner_pid 
# Wait for spinner to finish

# Main loop for the GUI
while true; do
    draw_desktop
    read -n 1 -s option
    case $option in
        1)
            text_editor
            ;;
        2)
            calculator
            ;;
        3)
            file_viewer
            ;;
        4)
            guessing_game
            ;;
        5)
            shooting_star
            draw_ascii_art
            ;;
        6)
            check_for_updates
            ;;
        7)
            ReInstall
            ;;
        8)
            clear
            echo "Exiting Panes..."
            sleep 1
            exit 0
            ;;
        *)
            echo "Invalid option. Please select [1], [2], [3], [4], [5], [6], or [7]."
            sleep 1
            ;;
    esac
done