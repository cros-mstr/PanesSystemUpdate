#!/bin/bash
cd "$(dirname "$0")"
UPDATE_TITLE="Panes OS 1.05 "Beamed" "
UPDATE_DESC="Panes OS 1.05 Codenamed Beamed is an update that brings online application download functionality to your Panes experience. 10.5 is fresh from DTC and is ready for public use."
# Check if the script is running from a specific path
PARENT_DIR=$(dirname "$(pwd)")
INSTALLED_DIR="$PARENT_DIR/Installed"

VERSION=1.05
# Duration for initial animation in seconds
TOTAL_ANIMATION_DURATION=1/12
SPINNER_DELAY=0.25
TOTAL_UPDATE_DURATION=1
Berateur_url="https://github.com/cros-mstr/PanesUpdateAvailability/blob/e1f915424decca95f304a3fb946bea7fb6a762cb/VersionVerification"
#Are we up to date?
dater() {

get_signed_version() {
  local url="$1"
  local downloaded_content
  local signed_version

  downloaded_content=$(curl -sSL "$url")

  if [[ -n "$downloaded_content" ]]; then
    signed_version=$(echo "$downloaded_content" | grep "^CURRENTLY_SIGNED=" | cut -d'=' -f2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/"//g')
    echo "$signed_version"
    return 0
  else
    echo "ERROR: Failed verify your version. Will not check for updates."
    return 1
  fi
}

# Main part of the script

echo "Checking the signed version from: $verification_url"
current_signed_version=$(get_signed_version "$verification_url")

if [[ $? -eq 0 ]]; then
  echo "Currently signed version: '$current_signed_version'"
  if [[ "$current_signed_version" == "$expected_signed_version" ]]; then
    echo "Verification successful: The currently signed version matches the expected version '$expected_signed_version'."
    # Proceed with further actions if verification is successful
    echo "You're up to date on the latest Panes software!"
  else
    echo "Quick Software Update Available! You may upgrade to '$expected_signed_version'. Your current version is'$current_signed_version', which is now unsigned."
    exit 1
  fi
else
  echo "ERROR: Could not retrieve the signed version. Exiting script."
  exit 1
fi
}

# Function to draw the desktop
draw_desktop() {
#Before allowing any interaction with the system, ensure updates.
get_signed_version
    clear
    echo "============================="
    echo "|      Panes $VERSION       |"
    echo "|---------------------------|"
    echo "|  [1] Text Editor          |"
    echo "|  [2] Calculator           |"
    echo "|  [3] File Viewer          |"
    echo "|  [4] Guessing Game        |"
    echo "|  [5] Animation            |"
    echo "|  [6] Check for Updates    |"
    echo "|  [7] Reinstall Panes      |"
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
# Define PARENT_DIR and TOTAL_UPDATE_DURATION if not already defined
# For example:
# PARENT_DIR="$(pwd)" # Or adjust this to your actual parent directory logic
# TOTAL_UPDATE_DURATION=10 # Example duration in seconds

# Function to check and update individual applications in BootFolder/Applications
# Define PARENT_DIR and TOTAL_UPDATE_DURATION if not already defined
# For example:
# PARENT_DIR="$(pwd)" # Or adjust this to your actual parent directory logic
# TOTAL_UPDATE_DURATION=10 # Example duration in seconds

# Function for the Application Store
app_store() {
    clear
    echo "==================================="
    echo "|       Panes Application Store   |"
    echo "==================================="
    echo "Fetching available applications..."
    sleep 1

    local app_dir="$PARENT_DIR/BootFolder/Applications"
    local temp_repo_list="/tmp/panes_repo_list.txt"
    local base_repo_url="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/"

    # Fetch list of files in the main branch of the PanesSystemUpdate repo
    # This uses the GitHub API for file list, which is more reliable than scraping raw HTML
    # We'll then iterate through this list to get individual file contents
    if ! curl -s "https://api.github.com/repos/cros-mstr/PanesSystemUpdate/git/trees/main?recursive=1" | \
         grep -oP '"path": "\K[^"]*\.sh"' | \
         sed 's/\.sh$//' > "$temp_repo_list"; then
        echo "Error: Could not fetch application list from the repository."
        echo "Press [Enter] to return to the main menu."
        read -r
        return
    fi

    local app_files=()
    local app_display_names=()
    local app_statuses=()
    local app_versions=() # To store remote versions for comparison

    # Read each app filename from the temporary list
    while IFS= read -r app_name; do
        # Exclude Panes and README
        if [[ "$app_name" == "Panes" || "$app_name" == "README" ]]; then
            continue
        fi

        local full_app_filename="${app_name}.sh"
        local local_app_path="$app_dir/$full_app_filename"
        local remote_app_url="$base_repo_url$full_app_filename"
        local status="(Not Installed)"
        local remote_version="N/A"
        local local_version="0" # Assume 0 if not installed

        # Download the remote script temporarily to get its version and title
        local temp_remote_app_file="/tmp/remote_$full_app_filename"
        if curl -s "$remote_app_url" -o "$temp_remote_app_file"; then
            remote_version=$(grep '^VERSION=' "$temp_remote_app_file" | cut -d'=' -f2 | tr -d '"')
            if [ -z "$remote_version" ]; then
                remote_version="1.0" # Default if version not found in remote script
            fi
            
            # Check if installed locally
            if [ -f "$local_app_path" ]; then
                local_version=$(grep '^VERSION=' "$local_app_path" | cut -d'=' -f2 | tr -d '"')
                if [ -z "$local_version" ]; then
                    local_version="0" # Default if version not found in local script
                fi

                if (( $(echo "$remote_version > $local_version" | bc -l) )); then
                    status="(Installed - Update Available)"
                else
                    status="(Installed)"
                fi
            fi
            rm -f "$temp_remote_app_file"
        else
            echo "Warning: Could not fetch info for $full_app_filename. Skipping."
            continue # Skip if remote info can't be fetched
        fi

        app_files+=("$full_app_filename")
        app_display_names+=("$app_name") # Display name without .sh
        app_statuses+=("$status")
        app_versions+=("$remote_version") # Store remote version for future use
    done < "$temp_repo_list"

    rm -f "$temp_repo_list"

    if [ ${#app_files[@]} -eq 0 ]; then
        echo "No applications found in the store."
        echo "Press [Enter] to return to the main menu."
        read -r
        return
    fi

    # Display the store menu
    local i=0
    PS3="Select an application to install/update (or 0 to go back): "
    local options=()
    for ((idx=0; idx<${#app_files[@]}; idx++)); do
        options+=("${app_display_names[idx]} ${app_statuses[idx]}")
    done
    
    select choice in "${options[@]}" "Go Back"; do
        if [[ "$choice" == "Go Back" ]]; then
            break # Exit the select loop
        elif [[ -n "$choice" ]]; then
            local selected_index=$((REPLY - 1)) # REPLY is the number entered by user
            local selected_app_filename="${app_files[selected_index]}"
            local selected_app_name="${app_display_names[selected_index]}"
            local selected_app_url="$base_repo_url$selected_app_filename"
            local selected_app_status="${app_statuses[selected_index]}"

            echo "You selected: ${selected_app_name} ${selected_app_status}"
            echo "Preparing to install/update $selected_app_name..."
            sleep 1

            local local_app_path="$app_dir/$selected_app_filename"
            local action_message="install"
            if [[ "$selected_app_status" == *"(Installed"* ]]; then
                action_message="update"
            fi

            echo "Downloading $selected_app_name..."
            if curl -s "$selected_app_url" -o "$local_app_path"; then
                echo "Successfully downloaded and ${action_message}d $selected_app_name!"
                # Set execute permissions
                chmod +x "$local_app_path"
            else
                echo "Error: Failed to download $selected_app_name."
            fi
            echo "Press [Enter] to continue..."
            read -r
            break # Exit select loop after action
        else
            echo "Invalid option. Please enter a number from the list."
            # The select loop automatically re-prompts
        fi
    done < /dev/tty # Ensure select reads from terminal, similar to previous fix

    echo "Returning to main menu..."
    sleep 1
}

# Function to check and update individual applications in BootFolder/Applications
# Function to check and update individual applications in BootFolder/Applications
# Function to check and update individual applications in BootFolder/Applications
# Function to check and update individual applications in BootFolder/Applications
check_application_updates() {
    clear
    echo "==================================="
    echo "|   Checking Application Updates    |"
    echo "==================================="
    local app_dir="$PARENT_DIR/BootFolder/Applications"
    local updated_any_app=false

    if [ ! -d "$app_dir" ]; then
        echo "Applications directory '$app_dir' not found. Skipping application updates."
        echo "Press [Enter] to return to the main menu."
        read -r
        return
    fi

    echo "Scanning for .sh scripts in $app_dir..."
    sleep 1

    # Use a separate file descriptor for the while loop to prevent stdin conflicts
    # This redirects find's output to FD 3, keeping FD 0 (stdin) free for user input.
    find "$app_dir" -maxdepth 1 -type f -name "*.sh" | while read -r app_script <&3; do
        local app_filename=$(basename "$app_script")
        local local_app_version=""
        local remote_app_version=""
        local remote_app_title="N/A" # Default if not found
        local remote_app_desc="No description provided." # Default if not found
        local remote_app_url="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/$app_filename"

        echo -e "\n--- Checking $app_filename ---"

        local_app_version=$(grep '^VERSION=' "$app_script" | cut -d'=' -f2 | tr -d '"')

        if [ -z "$local_app_version" ]; then
            echo "  Warning: Could not find VERSION for $app_filename. Skipping this application."
            continue
        fi

        echo "  Fetching remote info for $app_filename from $remote_app_url..."
        local temp_remote_file="/tmp/remote_$app_filename"

        if ! curl -s "$remote_app_url" -o "$temp_remote_file"; then
            echo "  Error: Could not download remote $app_filename. Skipping this application."
            continue
        fi

        remote_app_version=$(grep '^VERSION=' "$temp_remote_file" | cut -d'=' -f2 | tr -d '"')
        temp_title=$(grep '^UPDATE_TITLE=' "$temp_remote_file" | cut -d'=' -f2 | tr -d '"')
        temp_desc=$(grep '^UPDATE_DESC=' "$temp_remote_file" | cut -d'=' -f2 | tr -d '"')

        if [ -n "$temp_title" ]; then
            remote_app_title="$temp_title"
        fi
        if [ -n "$temp_desc" ]; then
            remote_app_desc="$temp_desc"
        fi

        rm -f "$temp_remote_file"

        if [ -z "$remote_app_version" ]; then
            echo "  Error: Could not find VERSION in remote $app_filename. Skipping this application."
            continue
        fi

        echo "  Local Version: $local_app_version"
        echo "  Remote Version: $remote_app_version"

        if (( $(echo "$remote_app_version > $local_app_version" | bc -l) )); then
            echo -e "\n  ==================================="
            echo "  |   Update Available for $app_filename   |"
            echo "  ==================================="
            echo "  Title: $remote_app_title"
            echo "  Description: $remote_app_desc"
            echo "  -----------------------------------"
            
            # --- START OF REUSED CONFIRMATION LOGIC FROM PANES.SH UPDATE ---
            local confirm_app_update
            # Explicitly read from /dev/tty to bypass any stdin redirection from the `while read` loop
            read -r -p "  A new version ($remote_app_version) is available. Proceed with update? (y/n): " confirm_app_update < /dev/tty
            
            if [[ "$confirm_app_update" == "y" || "$confirm_app_update" == "Y" ]]; then
                echo "  Proceeding with $app_filename update..."
                local mini_total_steps=10
                local mini_step_duration=$(echo "$TOTAL_UPDATE_DURATION * 0.1 / $mini_total_steps" | bc -l)

                for ((i=0; i<=mini_total_steps; i++)); do
                    sleep "$mini_step_duration"
                    printf "\r  Progress: ["
                    for ((j=0; j<i; j++)); do
                        printf "#"
                    done
                    for ((j=i; j<mini_total_steps; j++)); do
                        printf " "
                    done
                    printf "] %d%%" "$((i * 100 / mini_total_steps))"
                done
                printf "\r"

                if curl -s "$remote_app_url" -o "$app_script"; then
                    echo "  $app_filename updated successfully!"
                    updated_any_app=true
                else
                    echo "  Error: Failed to download and update $app_filename."
                fi
            else
                echo "  Update for $app_filename cancelled by user."
                continue # Move to the next application in the loop
            fi
            # --- END OF REUSED CONFIRMATION LOGIC ---
        else
            echo "  $app_filename is already on the latest version ($local_app_version)."
        fi
    done 3<&0 # This redirects the original stdin (FD 0) to FD 3 for the `find` loop
              # and makes FD 0 available for `read` commands within the loop.

    echo -e "\n--- Application Update Check Complete ---"
    if [ "$updated_any_app" = true ]; then
        echo "Some application updates were applied."
    else
        echo "No application updates found or applied."
    fi
    echo "Press [Enter] to return to the main menu."
    read -r
}

# Main check_for_updates function
check_for_updates() {
    clear
    echo "============================="
    echo "|     Check for Updates     |"
    echo "============================="
    echo "Checking for updates..."
    sleep 1
    echo "Available update options:"
    echo "1. Regular update (stable version) - Panes.sh"
    echo "2. Dev Seeding (potentially unstable, latest features)"
    echo "3. Check and Update Applications" # New option
    read -p "Select an update type (1, 2, or 3): " update_choice

    case "$update_choice" in
        1)
            # Main Panes.sh update logic
            # Define the URL for the remote Panes.sh script
            REMOTE_PANES_URL="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/Panes.sh"
            LOCAL_VERSION="$VERSION" # Assuming VERSION is defined globally or in the calling script

            echo "Fetching remote Panes.sh version information..."
            # Download the remote Panes.sh temporarily to extract its version and update info
            if ! curl -s "$REMOTE_PANES_URL" -o /tmp/remote_Panes.sh; then
                echo "Error: Could not download remote Panes.sh to check version."
                echo "Update cancelled."
                read -r -p "Press [Enter] to return to the desktop."
                return
            fi

            # Extract the VERSION
            REMOTE_VERSION=$(grep '^VERSION=' /tmp/remote_Panes.sh | cut -d'=' -f2 | tr -d '"')
            # Extract UPDATE_TITLE
            REMOTE_UPDATE_TITLE=$(grep '^UPDATE_TITLE=' /tmp/remote_Panes.sh | cut -d'=' -f2 | tr -d '"')
            # Extract UPDATE_DESC
            REMOTE_UPDATE_DESC=$(grep '^UPDATE_DESC=' /tmp/remote_Panes.sh | cut -d'=' -f2 | tr -d '"')

            if [ -z "$REMOTE_VERSION" ]; then
                echo "Error: Could not find VERSION in the remote Panes.sh script, or it's empty."
                rm -f /tmp/remote_Panes.sh
                echo "Update cancelled."
                read -r -p "Press [Enter] to return to the desktop."
                return
            fi

            rm -f /tmp/remote_Panes.sh # Clean up the temporary file

            echo "Current Panes.sh Version: $LOCAL_VERSION"
            echo "Available Panes.sh Version: $REMOTE_VERSION"

            if (( $(echo "$REMOTE_VERSION > $LOCAL_VERSION" | bc -l) )); then
                echo -e "\n============================="
                echo "|      Update Available     |"
                echo "============================="
                echo "Title: $REMOTE_UPDATE_TITLE"
                echo "Description: $REMOTE_UPDATE_DESC"
                echo "-----------------------------"
                read -p "A new Panes.sh version ($REMOTE_VERSION) is available. Proceed with update? (y/n): " confirm_update
                # REVISED LOGIC FOR CONFIRMATION
                if [[ "$confirm_update" == "y" || "$confirm_update" == "Y" ]]; then
                    echo "Proceeding with Panes.sh update..."
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
                    git clone https://github.com/cros-mstr/PanesSystemUpdate.git
                    echo -e "\n\nUpdate downloaded. Applying changes..."

                    # Change directory back up one level and copy the script
                    cd "$PARENT_DIR" || exit
                    cp -f PanesSystemUpdate/Panes.sh BootFolder/Panes.sh # Copy only Panes.sh
                    echo "Panes.sh copied."

                    # Displaying a progress bar (again) for unpacking
                    local total_steps_unpack=20 # Total number of steps to display progress
                    local step_duration_unpack=$(echo "$TOTAL_UPDATE_DURATION * 10 / $total_steps_unpack" | bc -l) # Duration of each step
                    for ((i=0; i<=total_steps_unpack; i++)); do
                        sleep "$step_duration_unpack"
                        printf "\rUnpacking: ["
                        for ((j=0; j<i; j++)); do
                            printf "#"
                        done
                        for ((j=i; j<total_steps_unpack; j++)); do
                            printf " "
                        done
                        printf "] %d%%" "$((i * 10 / total_steps_unpack))"
                    done
                    cp -f -v PanesSystemUpdate/* BootFolder/ # Copy remaining files from cloned repo
                    echo -e "\n\nUnpacked. Cleaning and applying changes..."
                    # Clean up the cloned repository
                    rm -rf PanesSystemUpdate
                    echo "Panes.sh update applied successfully!"
                else # User did not confirm 'y' or 'Y'
                    echo "Panes.sh update cancelled by user."
                    read -r -p "Press [Enter] to return to the desktop."
                    return
                fi
            else
                echo "Panes.sh is already on the latest version ($LOCAL_VERSION)."
            fi
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
            cd "$PARENT_DIR" || exit
            sudo bash Functions/EnvironmentUpdater.sh
            sleep 20
            sudo bash DevSeed.panes/Upgrader.sh
            sleep 10
            ;;
        3)
            # Call the new function for application updates
            check_application_updates
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
