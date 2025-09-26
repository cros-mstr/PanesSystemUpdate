#!/bin/bash
# Debug script to print out what the Panes app store sees in RepoAvailableApps

REPO_URL="https://raw.githubusercontent.com/cros-mstr/PanesSystemUpdate/refs/heads/main/RepoAvailableApps"
TEMP_FILE="/tmp/panes_debug_repo_apps_list_$$.txt"

# Download the RepoAvailableApps file
if ! curl -s "$REPO_URL" -o "$TEMP_FILE"; then
    echo "Error: Could not download RepoAvailableApps from $REPO_URL"
    exit 1
fi

echo "--- Raw contents of RepoAvailableApps ---"
cat "$TEMP_FILE"
echo "--- Parsed app names (as the store sees them) ---"

while IFS= read -r app_name_raw; do
    # Skip empty lines or comments
    if [[ -z "$app_name_raw" || "$app_name_raw" =~ ^# ]]; then
        continue
    fi
    # Remove leading/trailing whitespace
    app_base_name=$(echo "$app_name_raw" | xargs)
    # Print the parsed name and the corresponding .sh filename
    echo "App: '$app_base_name'  (Script: ${app_base_name}.sh)"
done < "$TEMP_FILE"

rm -f "$TEMP_FILE"
