#!/bin/bash

# Get terminal dimensions
rows=$(tput lines)
cols=$(tput cols)

# Function to print spaces with a given background color code
draw_background() {
  local color_code="$1"
  for ((i=0; i<rows; i++)); do
    tput cup "$i" 0
    printf "$color_code"
    for ((j=0; j<cols; j++)); do
      printf " "
    done
    printf "\e[0m\n" # Reset color and move to the next line
  done
}

# Paint the terminal white
draw_background "\e[47m"
sleep 2 # Keep white for a moment

# Paint the terminal black
draw_background "\e[40m"

echo "Configuration in Progress..." # Add a newline at the end
