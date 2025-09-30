#!/bin/bash
cd "$(dirname "$0")"

# Set terminal background color to #00EEFF
#Changed to for readability and less strain
printf '\033]11;#0F9096\007'

#todo Add an installer app to RepoAvailableApps
#Add a Classic mode that is the old panes with no app store
#Add a OOBE (Out Of Box Experience) for first-time users
#Login system coming soon
#history
#1052 beamed
#1053 ontrack
#1054 appenhanced
#1055 Spectrum
#20 Swapper
#21  Refresh
#22 Snapper
#Coming Soon in Beta: Installer
UPDATE_TITLE="Panes 2.1 "Refresh" "
UPDATE_DESC="Panes 2.1 Refresh is the latest and greatest version of Panes. It includes a new application store, a revamped user interface, and many bug fixes and performance improvements. Enjoy!"
#PanesDR Coming Soon
#Bugs, bugs, BUGS!!!
PARENT_DIR=$(dirname "$(pwd)")
INSTALLED_DIR="$PARENT_DIR/Installed"

VERSION=2.1
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
    clear
    # Get terminal size
    local term_rows term_cols
    term_rows=$(tput lines)
    term_cols=$(tput cols)

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
# ===================================================================
# Application Management Functions (place these here)
# ===================================================================

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

# Function to uninstall an application
uninstall_application() {
    local app_full_path="$1"
    local app_display_name=$(basename "$app_full_path" .sh)
    clear
    echo "==================================="
    echo "| Uninstalling $app_display_name |"
    echo "==================================="
    read -r -p "Are you sure you want to uninstall $app_display_name? (y/n): " confirm_uninstall < /dev/tty
    confirm_uninstall=$(echo "$confirm_uninstall" | tr '[:upper:]' '[:lower:]' | xargs)
    if [[ "$confirm_uninstall" == "y" ]]; then
        if rm -f "$app_full_path"; then
            echo "$app_display_name uninstalled successfully!"
        else
            echo "Error: Failed to uninstall $app_display_name. Check permissions for $app_full_path."
        fi
    else
        echo "Uninstallation of $app_display_name cancelled."
    fi
    echo "Press [Enter] to return to the desktop."
    read -r < /dev/tty
}

# Menu for an installed application (this calls launch_application and uninstall_application)
app_menu() {
    local selected_app_filename="$1"
    local app_full_path="./Applications/$selected_app_filename"
    local app_display_name=$(basename "$selected_app_filename" .sh)
    while true; do
        clear
        echo "==================================="
        echo "|   $app_display_name Options    |"
        echo "==================================="
        echo "|  [1] Launch $app_display_name   |"
        echo "|  [2] Uninstall $app_display_name|"
        echo "|  [0] Back to Desktop          |"
        echo "==================================="
        read -r -p "Enter your choice: " app_option < /dev/tty
        case $app_option in
            1)
                if [ -f "$app_full_path" ]; then
                    launch_application "$app_full_path" # <--- Called here
                else
                    echo "Error: $app_display_name not found at $app_full_path. It might have been manually removed."
                    sleep 2
                fi
                ;;
            2)
                uninstall_application "$app_full_path" # <--- Called here
                break
                ;;
            0)
                break
                ;;
            *)
                echo "Invalid option. Please choose 1, 2, or 0."
                sleep 1
                ;;
        esac
    done
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
# Function for the Application Store
# Function for the Application Store
# Function for the Application Store
app_store() {
    clear
    echo -e "\e[44;97m===================================\e[0m"
    echo -e "\e[44;97m|     \e[1mPanes Application Store\e[0;44;97m   |\e[0m"
    echo -e "\e[44;97m===================================\e[0m"
    echo -e "\e[36mFetching available applications...\e[0m"
    sleep 1

    local app_dir="./Applications"
    mkdir -p "$app_dir" # Ensure the applications directory exists
    local repo_apps_list_url="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/RepoAvailableApps"
    local base_repo_url="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/"
    local temp_repo_list_file="/tmp/panes_repo_apps_list_$$_$(date +%s).txt" # Unique temp file for the list

    # Fetch the list of available applications from the text file
    echo "Downloading app list from $repo_apps_list_url..."
    if ! curl -s "$repo_apps_list_url" -o "$temp_repo_list_file"; then
        echo "Error: Failed to download the list of available applications."
        rm -f "$temp_repo_list_file"
        echo "Please ensure your internet connection is stable and the repository URL is correct."
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi

    local app_filenames_in_repo=() # Stores the full filenames (e.g., "Calculator.sh")
    local app_display_names=()
    local app_statuses=()
    local app_versions=() # To store remote versions for comparison
    local app_descriptions=() # To store app descriptions

    # Read each app filename (without .sh) from the downloaded list
    echo "Gathering app details..."
    while IFS= read -r app_name_raw; do
        # Basic validation: skip empty lines or lines that might be comments
        if [[ -z "$app_name_raw" || "$app_name_raw" =~ ^# ]]; then
            continue
        fi

        # Remove leading/trailing whitespace
        local app_base_name=$(echo "$app_name_raw" | xargs) # e.g., "Calculator"

        # Ensure it's a valid app name (e.g., doesn't contain / or other bad chars)
        if [[ "$app_base_name" =~ [[:space:]] || "$app_base_name" =~ / ]]; then
             echo "Warning: Invalid app name '$app_name_raw' found in RepoAvailableApps. Skipping."
             continue
        fi

        local full_script_name="${app_base_name}.sh" # This is the consistent name, e.g., "Calculator.sh"
        local local_app_path="$app_dir/$full_script_name"
        local remote_app_url="$base_repo_url$full_script_name"
        local status="(Not Installed)"
        local remote_version="N/A"
        local local_version="0" # Assume 0 if not installed or version not found

        # Download the remote script temporarily to get its version, title, and description
        local temp_remote_app_file="/tmp/remote_${full_script_name}_$$_$(date +%s)" # Unique temp file for each app
        if ! curl -s "$remote_app_url" -o "$temp_remote_app_file"; then
            echo -e "\e[33mWarning: Could not download remote info for '$full_script_name'. Skipping this app.\e[0m"
            rm -f "$temp_remote_app_file"
            continue # Skip if remote info can't be fetched
        fi

        remote_version=$(grep '^VERSION=' "$temp_remote_app_file" | cut -d'=' -f2 | tr -d '"')
        remote_desc=$(grep '^UPDATE_DESC=' "$temp_remote_app_file" | cut -d'=' -f2- | tr -d '"')
        if [ -z "$remote_version" ]; then
            remote_version="1.0" # Default if version not found in remote script
        fi
        if [ -z "$remote_desc" ]; then
            remote_desc="No description available."
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
        rm -f "$temp_remote_app_file" # Clean up temporary remote app file

        app_filenames_in_repo+=("$full_script_name") # Store the full filename with .sh
        app_display_names+=("$app_base_name")       # Store the base name for display
        app_statuses+=("$status")
        app_versions+=("$remote_version") # Store remote version for future use
        app_descriptions+=("$remote_desc")
    done < "$temp_repo_list_file"

    rm -f "$temp_repo_list_file" # Clean up the main repo list file

    if [ ${#app_filenames_in_repo[@]} -eq 0 ]; then
        echo "No applications found in the store based on the repository list."
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi

    # Display the store menu with color and descriptions
    PS3=$'\e[1;36mSelect an application to install/update (or 0 to go back): \e[0m'
    local options=()
    for ((idx=0; idx<${#app_filenames_in_repo[@]}; idx++)); do
        options+=("${app_display_names[idx]} ${app_statuses[idx]}")
    done

    select choice in "${options[@]}" "Go Back"; do
        if [[ "$choice" == "Go Back" ]]; then
            break # Exit the select loop
        elif [[ -n "$choice" ]]; then
            local selected_index=$((REPLY - 1)) # REPLY is the number entered by user

            # Input validation to prevent out-of-bounds access
            if (( selected_index < 0 || selected_index >= ${#app_filenames_in_repo[@]} )); then
                echo -e "\e[31mInvalid selection number. Please choose a number from the list or 0.\e[0m"
                continue
            fi

            local selected_app_filename="${app_filenames_in_repo[selected_index]}" # This now has the correct .sh
            local selected_app_name="${app_display_names[selected_index]}"
            local remote_app_url="$base_repo_url$selected_app_filename" # Use the correct filename
            local selected_app_status="${app_statuses[selected_index]}"
            local selected_app_desc="${app_descriptions[selected_index]}"

            echo -e "\e[1;32mYou selected: ${selected_app_name} ${selected_app_status}\e[0m"
            echo -e "\e[36mDescription: $selected_app_desc\e[0m"
            echo "Preparing to install/update $selected_app_name..."
            sleep 1

            local local_app_path="$app_dir/$selected_app_filename" # Use the correct filename for local path
            local action_message="install"
            if [[ "$selected_app_status" == *"(Installed"* ]]; then
                action_message="update"
            fi

            echo "Downloading $selected_app_name..."
            # Explicit check for curl failure during final application download
            if curl -s "$remote_app_url" -o "$local_app_path"; then
                echo -e "\e[32mSuccessfully downloaded and ${action_message}d $selected_app_name!\e[0m"
                # Set execute permissions
                chmod +x "$local_app_path"
            else
                echo -e "\e[31mError: Failed to download $selected_app_name. Please check disk space and permissions for '$local_app_path' and network connection.\e[0m"
            fi
            echo -e "\e[36mPress [Enter] to continue...\e[0m"
            read -r < /dev/tty # Ensure this read also uses /dev/tty
            break # Exit select loop after action
        else
            echo -e "\e[31mInvalid option. Please enter a number from the list.\e[0m"
            # The select loop automatically re-prompts
        fi
    done < /dev/tty # Ensure select reads from terminal

    echo -e "\e[36mReturning to main menu...\e[0m"
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
    local app_dir="./Applications"
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

                    # --- START OF REUSED PROGRESS BAR LOGIC ---
                    for ((j=0; j<i; j++)); do
                        printf "#"
                    done
                    for ((j=i; j<mini_total_steps; j++)); do
                        printf " "
                    done
                    printf "] %d%%" "$((i * 100 / mini_total_steps))"
                    # --- END OF REUSED PROGRESS BAR LOGIC ---
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
    done 3<&0 # This redirects the original stdin (FD 0) to FD 3 for the `find` loop.
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
# New function for the Developer Update (keep this as is, defined before check_for_updates)
# New function for the Developer Update
dev_update() {
    clear
    echo "==================================="
    echo "|     Panes Developer Update      |"
    echo "==================================="
    echo "This update channel requires a developer key."
    read -r -s -p "Enter Developer Key: " user_entered_dev_key # Changed variable name to avoid confusion with file content
    echo # Newline after silent input

    local dev_key_url="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/DeveloperKey"
    local env_updater_url="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/EnvironmentUpdater.sh"
    local panes_glimpse_url="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/PanesGlimpse.sh"

    local temp_dev_key_file="/tmp/panes_devkey_$$_$(date +%s).txt"
    local temp_env_updater_file="/tmp/panes_env_updater_$$_$(date +%s).sh"
    local temp_panes_glimpse_file="/tmp/panes_glimpse_$$_$(date +%s).sh"

    echo "Verifying developer key..."
    if ! curl -s "$dev_key_url" -o "$temp_dev_key_file"; then
        echo "Error: Could not download developer key file for verification. Check internet connection or URL."
        rm -f "$temp_dev_key_file" 2>/dev/null
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi

    # *** CRITICAL CHANGE HERE ***
    #
    local stored_dev_key=$(grep '^devkey=' "$temp_dev_key_file" | cut -d'=' -f2 | xargs)
    # ^^^ This finds the line starting with "devkey=", cuts by "=", takes the second field (the value), and trims whitespace.

    rm -f "$temp_dev_key_file" 2>/dev/null # Clean up temp file

    # Now compare the user's input with the extracted key
    if [[ "$user_entered_dev_key" != "$stored_dev_key" ]]; then
        echo "Developer Key Mismatch. Access Denied."
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi

    echo "Developer Key Accepted. Proceeding with Developer Update..."
    sleep 1

    # Step 1: Download and run EnvironmentUpdater.sh
    echo "Downloading EnvironmentUpdater.sh..."
    if ! curl -s "$env_updater_url" -o "$temp_env_updater_file"; then
        echo "Error: Failed to download EnvironmentUpdater.sh. Aborting."
        rm -f "$temp_env_updater_file" 2>/dev/null
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi
    chmod +x "$temp_env_updater_file"

    echo "Running EnvironmentUpdater.sh..."
    ( bash "$temp_env_updater_file" )
    local env_updater_exit_code=$?
    rm -f "$temp_env_updater_file" 2>/dev/null

    if [ "$env_updater_exit_code" -ne 0 ]; then
        echo "EnvironmentUpdater.sh completed with errors (Exit Code: $env_updater_exit_code). Update may be incomplete."
        echo "Press [Enter] to continue or to return to the main menu."
        read -r < /dev/tty
        return
    else
        echo "EnvironmentUpdater.sh completed successfully."
    fi

    # Step 2: Download and run PanesGlimpse.sh (which will likely replace Panes.sh)
    echo "Downloading PanesGlimpse.sh..."
    if ! curl -s "$panes_glimpse_url" -o "$temp_panes_glimpse_file"; then
        echo "Error: Failed to download PanesGlimpse.sh. Aborting."
        rm -f "$temp_panes_glimpse_file" 2>/dev/null
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi
    chmod +x "$temp_panes_glimpse_file"

    echo "Running PanesGlimpse.sh to finalize update..."
    exec bash "$temp_panes_glimpse_file" "$PARENT_DIR"
    echo "Error: Failed to execute PanesGlimpse.sh unexpectedly."
    echo "Press [Enter] to return to the main menu."
    read -r < /dev/tty
}
# Modified check_for_updates function 
check_for_updates() {
    clear
    echo "==================================="
    echo "|        Checking for Updates     |"
    echo "==================================="
    echo "[1] Update Panes.sh (Standard)"
    echo "[2] Check and Update Applications"
    echo "[3] Developer Update (Requires Key)" # <-- Developer Update option here
    echo "[4] Factory Reset"
    echo "[0] Back to Main Menu"
    echo "==================================="
    read -r -p "Enter your choice: " update_option < /dev/tty

    case $update_option in
        1)
            echo "Checking for Panes.sh standard update..."
            local LOCAL_VERSION="$VERSION"
            local REMOTE_VERSION=""
            local REMOTE_TITLE=""
            local REMOTE_DESC=""
            local VERIFICATION_URL="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/Panes.sh"
            local DOWNLOAD_URL="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/Panes.sh"
            local TEMP_UPDATE_FILE="/tmp/Panes_standard_update_$$.sh"
            local CURRENT_SCRIPT_PATH="$0"

            if ! curl -s "$VERIFICATION_URL" -o "$TEMP_UPDATE_FILE"; then
                echo "Error: Could not download remote Panes.sh for version check."
                echo "Press [Enter] to return."
                read -r < /dev/tty
                return
            fi

            REMOTE_VERSION=$(grep '^VERSION=' "$TEMP_UPDATE_FILE" | cut -d'=' -f2 | tr -d '"')
            REMOTE_TITLE=$(grep '^UPDATE_TITLE=' "$TEMP_UPDATE_FILE" | cut -d'=' -f2 | tr -d '"')
            REMOTE_DESC=$(grep '^UPDATE_DESC=' "$TEMP_UPDATE_FILE" | cut -d'=' -f2 | tr -d '"')

            if [ -z "$REMOTE_VERSION" ]; then
                echo "Error: Could not determine remote Panes.sh version."
                rm -f "$TEMP_UPDATE_FILE"
                echo "Press [Enter] to return."
                read -r < /dev/tty
                return
            fi

            echo "Local Panes.sh Version: $LOCAL_VERSION"
            echo "Remote Panes.sh Version: $REMOTE_VERSION"
            echo "Update Title: $REMOTE_TITLE"
            echo "Update Description: $REMOTE_DESC"

            # Always update if the user chooses to, even if the version is the same
            read -r -p "Proceed with update? (y/n): " confirm_update < /dev/tty
            if [[ "$confirm_update" =~ ^[Yy]$ ]]; then
                # Call the update screen

                # Download the updated script to a temp file first
                local NEW_SCRIPT_TEMP="/tmp/Panes_new_script_$$.sh"
                if curl -s "$DOWNLOAD_URL" -o "$NEW_SCRIPT_TEMP"; then
                    # Replace the running script atomically
                    if mv "$NEW_SCRIPT_TEMP" "$CURRENT_SCRIPT_PATH" && chmod +x "$CURRENT_SCRIPT_PATH"; then
                        echo "Panes.sh updated successfully to version $REMOTE_VERSION!"
                        echo "Restarting Panes.sh to apply the update..."
                        sleep 2
                        exec bash "$CURRENT_SCRIPT_PATH" # Restart the updated script
                    else
                        echo "Error: Failed to replace the existing Panes.sh script. Update aborted."
                        rm -f "$NEW_SCRIPT_TEMP"
                        echo "Press [Enter] to return."
                        read -r < /dev/tty
                        return
                    fi
                else
                    echo "Error: Failed to download the updated script. Update aborted."
                    rm -f "$TEMP_UPDATE_FILE"
                    echo "Press [Enter] to return."
                    read -r < /dev/tty
                    return
                fi
            else
                echo "Panes.sh update cancelled by user."
            fi
            rm -f "$TEMP_UPDATE_FILE"
            echo "Press [Enter] to return to the desktop."
            read -r < /dev/tty
            ;;
        2)
            check_application_updates
            ;;
        3)
            dev_update
            ;;
        4)
            factory_reset
            ;;
        0)
            echo "Returning to main menu."
            sleep 1
            ;;
        *)
            echo "Invalid option. Please choose 1, 2, 3, 4, or 0."
            sleep 1
            ;;
    esac
}

# Factory Reset Function
factory_reset() {
    clear
    echo "==================================="
    echo "|         Factory Reset           |"
    echo "==================================="
    echo "[1] Reset Panes.sh to Default (Local)"
    echo "[2] Download Latest Panes.sh (Internet)"
    echo "[0] Cancel"
    echo "==================================="
    read -r -p "Enter your choice: " reset_option < /dev/tty

    case $reset_option in
        1)
            echo "Resetting Panes.sh to default (local backup)..."
            local DEFAULT_SCRIPT_PATH="./PanesBackup.sh"
            if [ -f "$DEFAULT_SCRIPT_PATH" ]; then
                cp "$DEFAULT_SCRIPT_PATH" "$0"
                chmod +x "$0"
                echo "Panes.sh has been reset to its default state."
                echo "Please restart Panes.sh to apply changes."
                exit 0
            else
                echo "Error: Default backup script not found. Reset aborted."
                echo "Press [Enter] to return."
                read -r < /dev/tty
            fi
            ;;
        2)
            echo "Downloading the latest Panes.sh..."
            local DOWNLOAD_URL="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/Panes.sh"
            local TEMP_SCRIPT_PATH="/tmp/Panes_latest_$$.sh"
            if curl -s "$DOWNLOAD_URL" -o "$TEMP_SCRIPT_PATH"; then
                mv "$TEMP_SCRIPT_PATH" "$0"
                chmod +x "$0"
                echo "Panes.sh has been updated to the latest version."
                echo "Please restart Panes.sh to apply changes."
                exit 0
            else
                echo "Error: Failed to download the latest Panes.sh. Reset aborted."
                echo "Press [Enter] to return."
                read -r < /dev/tty
            fi
            ;;
        0)
            echo "Factory reset cancelled."
            sleep 1
            ;;
        *)
            echo "Invalid option. Please choose 1, 2, or 0."
            sleep 1
            ;;
    esac
}
# ===================================================================
# User Interface Functions (Text-Based UI)
# ===================================================================

# Function to draw the main menu
draw_main_menu() {
    clear
    echo "==================================="
    echo "|          Panes Menu            |"
    echo "==================================="
    echo "[1] Launch Application"
    echo "[2] Install New Application"
    echo "[3] Check for Updates"
    echo "[4] Developer Options"
    echo "[5] Factory Reset"
    echo "[0] Exit"
    echo "==================================="
}

# Function to handle user input for the main menu
handle_main_menu_input() {
    read -r -p "Enter your choice: " menu_option < /dev/tty

    case $menu_option in
        1)
            # Launch installed application menu
            echo "Launching installed applications..."
            sleep 1
            app_menu "${INSTALLED_APPS_GLOBAL[0]}"
            ;;
        2)
            # Open application store
            echo "Opening Panes Application Store..."
            sleep 1
            app_store
            ;;
        3)
            # Check for updates
            echo "Checking for updates..."
            sleep 1
            check_for_updates
            ;;
        4)
            # Developer options (if any)
            echo "Opening developer options..."
            sleep 1
            dev_update
            ;;
        5)
            # Factory reset
            echo "Starting factory reset process..."
            sleep 1
            factory_reset
            ;;
        0)
            # Exit the script
            echo "Exiting Panes. Goodbye!"
            sleep 1
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose a valid number."
            sleep 1
            ;;
    esac
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

# Function to handle user login
login() {
    clear
    echo "==================================="
    echo "|          Panes Login            |"
    echo "==================================="
    echo

    # Read user data from UserData file
    if [[ ! -f UserData ]]; then
        echo "Error 256: Login Data Non-existent. Please re-run setup."
        exit 1
    fi

    source UserData

    # Prompt for username
    read -r -p "Username: " entered_username
    if [[ "$entered_username" != "$USERNAME" ]]; then
        echo "Invalid username. Exiting..."
        exit 1
    fi

    # Prompt for password if it exists
    if [[ -n "$PASSWORD" ]]; then
        read -r -s -p "Password: " entered_password
        echo
        entered_password_hash=$(echo "$entered_password" | sha256sum | awk '{print $1}')
        if [[ "$entered_password_hash" != "$PASSWORD" ]]; then
            echo "Invalid password. Exiting..."
            exit 1
        fi
    fi

    echo "Login successful! Welcome, $USERNAME."
    sleep 2
}

# Function to play the startup animation
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

# Main script logic
main() {
    # Play the startup animation
    animate_ascii_art

    # Check if the UserData file exists
    if [[ ! -f UserData ]]; then
        # Run OOBE if UserData does not exist
        run_oobe
    fi

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
