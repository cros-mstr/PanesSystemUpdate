#Final response instructions
# Craft clear, effective, and engaging writing and prioritize clarity above all.*
# Use clear, straightforward language. Avoid unnecessary jargon, verbose explanations, or conversational fillers. Use contractions and avoid being overly formal.
# When appropriate based on the user prompt, you can vary your writing with diverse sentence structures and appropriate word choices to maintain engagement. Figurative language, idioms, and examples can be used to enhance understanding, but only when they improve clarity and do not make the text overly complex or verbose.
# When you give the user options, give fewer, high-quality options versus lots of lower-quality ones.
# Prefer active voice for a direct and dynamic tone.
# You can think through when to be warm and vibrant and can sound empathetic and nonjudgemental but don't show your thinking.
# Prioritize coherence over excessive fragmentation (e.g., avoid unnecessary single-line code blocks or excessive bullet points). When appropriate bold keywords in the response.
# Structure the response logically. If the response is more than a few paragraphs or covers different points or topics, remember to use markdown headings (##) along with markdown horizontal lines (---) above them.
# Think through the prompt and determine whether it makes sense to ask a question or make a statement at the end of your response to continue the conversation.

#!/bin/bash
cd "$(dirname "$0")" # Ensure script runs from its directory
#history 1052 BugSquasher Glimpse
#1054 Open Glimpse
UPDATE_TITLE="Panes OS 1.054 "Open Glimpse" "
UPDATE_DESC="Panes OS 1.054 is integrated into the public DTC repository. Expect bugs, glitches, and features not present in mainstream PanesOs. Please back up your data before proceeding."
# Check if the script is running from a specific path
PARENT_DIR=$(dirname "$(pwd)")
INSTALLED_DIR="$PARENT_DIR/Installed"

VERSION=1.054
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
    echo "============================="
    echo "|     Panes $VERSION         |"
    echo "|---------------------------|"
    echo "|  [1] Text Editor          |"
    echo "|  [2] Calculator           |"
    echo "|  [3] File Viewer          |"
    echo "|  [4] Guessing Game        |"
    echo "|  [5] Application Store    |"
    echo "|  [6] Animation            |"
    echo "|  [7] Check for Updates    |"
    echo "|  [8] Reinstall Panes      |"
    echo "|  [9] Installer            |" # New Installer option
    echo "|  [0] Exit                 |" # Exit is now 0
    echo "|---------------------------|"
    echo "|   Installed Applications  |"
    echo "|---------------------------|"

    local app_dir="$PARENT_DIR/BootFolder/Applications"
    local app_counter=10 # Start numbering installed apps from 10
    local temp_app_list="/tmp/panes_installed_apps_$$_$(date +%s).txt" # Temporary file

    # Clear the global array before re-populating it
    INSTALLED_APPS_GLOBAL=()

    if [ -d "$app_dir" ]; then
        # Find .sh files and put their full paths into a temporary file
        find "$app_dir" -maxdepth 1 -type f -name "*.sh" | sort > "$temp_app_list"

        # Now read from the temporary file into the array in the current shell
        while IFS= read -r app_path; do
            local app_filename=$(basename "$app_path")
            local app_display_name="${app_filename%.sh}"

            INSTALLED_APPS_GLOBAL+=("$app_filename")
            printf "|  [%d] %s\n" "$app_counter" "$app_display_name"
            ((app_counter++))
        done < "$temp_app_list"
    fi

    # Clean up the temporary file
    rm -f "$temp_app_list"

    echo "============================="
    echo "Desktop"
    echo "============================="
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
    local app_full_path="$PARENT_DIR/BootFolder/Applications/$selected_app_filename"
    local app_display_name=$(basename "$selected_app_filename" .sh)
    while true; do
        clear
        echo "==================================="
        echo "|    $app_display_name Options    |"
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
        "    **** ***** ** * ***** *********************************"
        "    * * ** ** * * * * * * * *"
        "    **** ******* * * * **** ***** * * *******"
        "    * ** ** * ** * * * * *"
        "    ****************************************** ******* *******"
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
    echo "|        Panes Application Store  |"
    echo "==================================="
    echo "Fetching available applications..."
    sleep 1

    local app_dir="$PARENT_DIR/BootFolder/Applications" # Retained as per original script structure
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

        # Download the remote script temporarily to get its version and title
        local temp_remote_app_file="/tmp/remote_${full_script_name}_$$_$(date +%s)" # Unique temp file for each app
        
        # Explicit check for curl failure during remote script metadata download
        if ! curl -s "$remote_app_url" -o "$temp_remote_app_file"; then
            echo "Warning: Could not download remote info for '$full_script_name'. Skipping this app."
            rm -f "$temp_remote_app_file"
            continue # Skip if remote info can't be fetched
        fi

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
        rm -f "$temp_remote_app_file" # Clean up temporary remote app file

        app_filenames_in_repo+=("$full_script_name") # Store the full filename with .sh
        app_display_names+=("$app_base_name")         # Store the base name for display
        app_statuses+=("$status")
        app_versions+=("$remote_version") # Store remote version for future use
    done < "$temp_repo_list_file"

    rm -f "$temp_repo_list_file" # Clean up the main repo list file

    if [ ${#app_filenames_in_repo[@]} -eq 0 ]; then
        echo "No applications found in the store based on the repository list."
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi

    # Display the store menu
    PS3="Select an application to install/update (or 0 to go back): "
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
                echo "Invalid selection number. Please choose a number from the list or 0."
                continue
            fi

            local selected_app_filename="${app_filenames_in_repo[selected_index]}" # This now has the correct .sh
            local selected_app_name="${app_display_names[selected_index]}"
            local remote_app_url="$base_repo_url$selected_app_filename" # Use the correct filename
            local selected_app_status="${app_statuses[selected_index]}"

            echo "You selected: ${selected_app_name} ${selected_app_status}"
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
                echo "Successfully downloaded and ${action_message}d $selected_app_name!"
                # Set execute permissions
                chmod +x "$local_app_path"
            else
                echo "Error: Failed to download $selected_app_name. Please check disk space and permissions for '$local_app_path' and network connection."
            fi
            echo "Press [Enter] to continue..."
            read -r < /dev/tty # Ensure this read also uses /dev/tty
            break # Exit select loop after action
        else
            echo "Invalid option. Please enter a number from the list."
            # The select loop automatically re-prompts
        fi
    done < /dev/tty # Ensure select reads from terminal

    echo "Returning to main menu..."
    sleep 1
}

---

## Panes Installer

This new function allows you to install local applications that you place into the `ToBeInstalled` directory.

```bash
# New Installer Function
installer() {
    clear
    echo "==================================="
    echo "|        Panes Installer          |"
    echo "==================================="

    local installer_dir="./ToBeInstalled" # Shares the same directory as the script
    mkdir -p "$installer_dir" # Ensure the directory exists

    if [ ! -d "$installer_dir" ]; then
        echo "Error: Could not create or access '$installer_dir'."
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi

    local installer_scripts_found=false
    local apps_data=() # Array to hold display name, version, full filename, and CanDowngrade status

    # Find bash scripts in the ToBeInstalled directory
    while IFS= read -r script_path; do
        installer_scripts_found=true
        local script_filename=$(basename "$script_path") # e.g., MyNewApp.sh
        local script_display_name="${script_filename%.sh}" # e.g., MyNewApp
        local version="N/A"
        local can_downgrade="false" # Default to false

        # Try to find the VERSION variable using awk for robustness
        local found_version=$(awk -F'=' '/^VERSION=/ {gsub(/"/, "", $2); print $2; exit}' "$script_path" | xargs)
        if [[ -n "$found_version" ]]; then
            version="$found_version"
        fi

        # Check for CanDowngrade variable
        local found_can_downgrade=$(awk -F'=' '/^CanDowngrade=/ {gsub(/"/, "", $2); print tolower($2); exit}' "$script_path" | xargs)
        if [[ "$found_can_downgrade" == "true" ]]; then
            can_downgrade="true"
        fi

        apps_data+=("$script_display_name|$version|$script_filename|$can_downgrade") # Store name, version, filename, and CanDowngrade
    done < <(find "$installer_dir" -maxdepth 1 -type f -name "*.sh" -print0 | xargs -0 sort) # Use -print0 and xargs -0 for robust handling of filenames with spaces

    if [ "$installer_scripts_found" = false ]; then
        echo "No installable applications found in '$installer_dir'."
        echo "Please add or create bash scripts (.sh files) in this directory for installation."
        echo "Example: 'touch ./ToBeInstalled/MyNewApp.sh' and then edit it with your app's code."
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi

    echo "Found installable applications:"
    echo "----------------------------------------------------------------"
    printf "%-30s %-15s %-15s\n" "Application Name" "Version" "CanDowngrade"
    echo "----------------------------------------------------------------"
    local option_counter=1
    local install_options=() # To store options for the select menu
    for item in "${apps_data[@]}"; do
        IFS='|' read -r name version filename can_downgrade_status <<< "$item"
        printf "[%2d] %-30s %-15s %-15s\n" "$option_counter" "$name" "$version" "$can_downgrade_status"
        install_options+=("$name|$filename|$version|$can_downgrade_status") # Store display name, filename, version, and CanDowngrade for select menu
        ((option_counter++))
    done
    echo "----------------------------------------------------------------"
    echo ""

    PS3="Select an application to install (or 0 to go back): "
    select install_choice in "${install_options[@]%%|*}" "Go Back"; do # Display only the name part
        if [[ "$install_choice" == "Go Back" ]]; then
            break # Exit the select loop
        elif [[ -n "$install_choice" ]]; then
            local selected_install_index=$((REPLY - 1))
            if (( selected_install_index < 0 || selected_install_index >= ${#install_options[@]} )); then
                echo "Invalid selection number. Please choose a number from the list or 0."
                continue
            fi
            
            # Extract filename, version, and CanDowngrade status from the stored option
            IFS='|' read -r selected_display_name selected_filename selected_version selected_can_downgrade <<< "${install_options[selected_install_index]}"
            local source_path="$installer_dir/$selected_filename"
            local destination_dir="$PARENT_DIR/BootFolder/Applications" # Install to the existing Applications folder
            local destination_path="$destination_dir/$selected_filename"

            echo "You selected to install: $selected_display_name (Version: $selected_version)"

            # Check if the application is already installed
            if [ -f "$destination_path" ]; then
                local current_installed_version=$(awk -F'=' '/^VERSION=/ {gsub(/"/, "", $2); print $2; exit}' "$destination_path" | xargs)
                if [ -z "$current_installed_version" ]; then
                    current_installed_version="0" # Default if existing app doesn't have a version
                fi
                echo "Currently installed version: $current_installed_version"

                # Compare versions
                if (( $(echo "$selected_version < $current_installed_version" | bc -l) )); then
                    echo "The installer is for an older version ($selected_version) than the currently installed version ($current_installed_version)."
                    if [[ "$selected_can_downgrade" == "true" ]]; then
                        read -r -p "This installer allows downgrades. Do you want to proceed anyway? (y/n): " confirm_downgrade < /dev/tty
                        if [[ ! "$confirm_downgrade" =~ ^[Yy]$ ]]; then
                            echo "Downgrade cancelled by user."
                            echo "Press [Enter] to continue..."
                            read -r < /dev/tty
                            break # Go back to installer menu
                        fi
                    else
                        echo "This installer does NOT allow downgrades. Installation denied."
                        echo "Press [Enter] to continue..."
                        read -r < /dev/tty
                        break # Go back to installer menu
                    fi
                elif (( $(echo "$selected_version == $current_installed_version" | bc -l) )); then
                    echo "This version ($selected_version) is already installed. Reinstallation will proceed."
                    read -r -p "Do you want to proceed with reinstallation? (y/n): " confirm_reinstall < /dev/tty
                    if [[ ! "$confirm_reinstall" =~ ^[Yy]$ ]]; then
                        echo "Reinstallation cancelled by user."
                        echo "Press [Enter] to continue..."
                        read -r < /dev/tty
                        break # Go back to installer menu
                    fi
                fi
                # If selected_version > current_installed_version, it's an upgrade, proceed normally.
            fi

            echo "Installing $selected_display_name..."

            mkdir -p "$destination_dir" # Ensure destination directory exists

            if cp -f "$source_path" "$destination_path"; then
                chmod +x "$destination_path"
                echo "Successfully installed $selected_display_name to '$destination_path'!"
                echo "You may now launch this application from the desktop."
                # Optional: Uncomment the following block if you want to offer to delete the original from ToBeInstalled
                # read -r -p "Delete original script from ToBeInstalled directory? (y/n): " delete_confirm < /dev/tty
                # if [[ "$delete_confirm" =~ ^[Yy]$ ]]; then
                #       rm -f "$source_path"
                #       echo "$selected_display_name removed from ToBeInstalled."
                # fi
            else
                echo "Error: Failed to install $selected_display_name. Check permissions or disk space."
            fi
            echo "Press [Enter] to continue..."
            read -r < /dev/tty # Ensure this read also uses /dev/tty
            break # Exit select loop after action
        else
            echo "Invalid option. Please enter a number from the list."
        fi
    done < /dev/tty # Ensure select reads from terminal

    echo "Returning to main menu..."
    sleep 1
}

# Function to check and update individual applications in BootFolder/Applications
check_application_updates() {
    clear
    echo "==================================="
    echo "|    Checking Application Updates   |"
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
        local remote_app_url="[https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/$app_filename](https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/$app_filename)"

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
            echo "  |    Update Available for $app_filename    |"
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
# New function for the Developer Update (keep this as is, defined before check_for_updates)
dev_update() {
    clear
    echo "==================================="
    echo "|      Panes Developer Update     |"
    echo "==================================="
    echo "This update channel requires a developer key."
    read -r -s -p "Enter Developer Key: " user_entered_dev_key # Changed variable name to avoid confusion with file content
    echo # Newline after silent input

    local dev_key_url="[https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/DeveloperKey](https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/DeveloperKey)"
    local env_updater_url="[https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/EnvironmentUpdater.sh](https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/EnvironmentUpdater.sh)"
    local panes_glimpse_url="[https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/PanesGlimpse.sh](https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/PanesGlimpse.sh)"

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
    # Extract only the value of 'devkey' from the downloaded file
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
        echo "Environment Updater failed with exit code $env_updater_exit_code. Aborting Developer Update."
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi

    # Step 2: Download and replace PanesGlimpse.sh
    echo "Downloading PanesGlimpse.sh (main application)..."
    if ! curl -s "$panes_glimpse_url" -o "$PARENT_DIR/PanesGlimpse.sh"; then
        echo "Error: Failed to download PanesGlimpse.sh. Your system might be unstable."
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi
    chmod +x "$PARENT_DIR/PanesGlimpse.sh"
    echo "PanesGlimpse.sh updated successfully!"

    echo "Developer Update Complete!"
    echo "Press [Enter] to return to the main menu."
    read -r < /dev/tty
}

# Function to check for updates (main system update)
check_for_updates() {
    clear
    echo "==================================="
    echo "|      Checking for Updates       |"
    echo "==================================="
    local update_url="[https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/PanesGlimpse.sh](https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/PanesGlimpse.sh)"
    local temp_update_script="/tmp/PanesGlimpse_latest.sh"

    echo "Fetching latest update information..."
    # Download the latest version of PanesGlimpse.sh to a temporary file
    if ! curl -s "$update_url" -o "$temp_update_script"; then
        echo "Error: Failed to download update information. Please check your internet connection."
        rm -f "$temp_update_script" 2>/dev/null
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi

    # Extract version from the downloaded temporary script
    local latest_version=$(grep '^VERSION=' "$temp_update_script" | cut -d'=' -f2 | tr -d '"')
    local latest_update_title=$(grep '^UPDATE_TITLE=' "$temp_update_script" | cut -d'=' -f2 | tr -d '"')
    local latest_update_desc=$(grep '^UPDATE_DESC=' "$temp_update_script" | cut -d'=' -f2 | tr -d '"')

    # Ensure current script has a version defined
    if [ -z "$VERSION" ]; then
        echo "Error: Current Panes version not defined. Cannot check for updates."
        rm -f "$temp_update_script" 2>/dev/null
        echo "Press [Enter] to return to the main menu."
        read -r < /dev/tty
        return
    fi

    echo "Current Panes OS Version: $VERSION"
    echo "Latest Available Version: $latest_version"

    if (( $(echo "$latest_version > $VERSION" | bc -l) )); then
        echo -e "\n==================================="
        echo "|       New Update Available!     |"
        echo "==================================="
        echo "Title: $latest_update_title"
        echo "Description: $latest_update_desc"
        echo "-----------------------------------"
        
        local confirm_update
        read -r -p "A new version ($latest_version) is available. Proceed with update? (y/n): " confirm_update < /dev/tty
        
        if [[ "$confirm_update" == "y" || "$confirm_update" == "Y" ]]; then
            echo "Proceeding with update..."
            local current_script_path="$0" # Path to the currently running script
            local temp_target_path="$current_script_path.temp_update"

            # Simulate download/installation progress
            local total_steps=10
            local step_duration=$(echo "$TOTAL_UPDATE_DURATION / $total_steps" | bc -l)
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
            printf "\r"

            # Atomically replace the old script with the new one
            if mv -f "$temp_update_script" "$current_script_path"; then
                chmod +x "$current_script_path"
                echo "Panes OS updated successfully to version $latest_version!"
                echo "Please restart Panes OS for changes to take full effect."
                echo "Press [Enter] to restart Panes OS."
                read -r < /dev/tty
                # Execute the updated script
                exec bash "$current_script_path"
            else
                echo "Error: Failed to apply the update. Manual intervention may be required."
            fi
        else
            echo "Update cancelled by user."
        fi
    elif (( $(echo "$latest_version < $VERSION" | bc -l) )); then
        echo "You are currently running a newer version ($VERSION) than the latest available official update ($latest_version)."
        echo "This might be due to being on a developer build or a pre-release version."
        echo "No action taken."
    else
        echo "Panes OS is already up to date ($VERSION)."
    fi

    rm -f "$temp_update_script" 2>/dev/null
    echo "Press [Enter] to return to the main menu."
    read -r < /dev/tty
}

main_menu() {
    local choice
    while true; do
        draw_desktop
        read -r -p "Enter your choice: " choice < /dev/tty

        # Check if the choice is for an installed application
        if (( choice >= 10 && choice < 10 + ${#INSTALLED_APPS_GLOBAL[@]} )); then
            local app_index=$((choice - 10))
            app_menu "${INSTALLED_APPS_GLOBAL[app_index]}"
            continue # Return to the main menu loop
        fi

        case "$choice" in
            1)
                echo "Opening Text Editor..."
                sleep 1
                echo "Text Editor functionality goes here."
                echo "Press [Enter] to return to the desktop."
                read
