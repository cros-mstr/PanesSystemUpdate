#!/bin/bash

# Clear the screen
clear

# Display the header
echo "UPDATING FIRMWARE"
echo ""

# Set total time in seconds
total_seconds=60

# Set bar length
bar_length=50

# Loop for the total duration
for ((i=0; i<=total_seconds; i++)); do
    # Calculate the percentage completed
    percentage=$(( (i * 100) / total_seconds ))

    # Calculate the number of filled characters
    filled_chars=$(( (percentage * bar_length) / 100 ))

    # Create the loading bar string
    bar_string=""
    for ((j=0; j<filled_chars; j++)); do
        bar_string+="#"
    done

    # Pad the rest of the bar with spaces
    for ((k=0; k<(bar_length - filled_chars); k++)); do
        bar_string+=" "
    done

    # Print the loading bar and percentage on the same line
    printf "\r[%s] %d%%" "$bar_string" "$percentage"

    # Wait for one second
    sleep 1
done

echo ""
echo "Firmware update complete!"