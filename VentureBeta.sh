#!/bin/bash
echo "This is a Brave Educational Test App!"
echo "Expect bugs! To update, uninstall then re-install!"
# Check for bc dependency
if ! command -v bc &> /dev/null; then
    echo "Error: 'bc' is not installed. Install it with 'sudo apt install bc' or 'brew install bc'."
    exit 1
fi

# --- Configuration ---
cols=$(tput cols)
lines=$(tput lines)
SCREEN_WIDTH=$(( cols > 80 ? 80 : cols ))
SCREEN_HEIGHT=$(( lines > 20 ? 15 : lines - 5 ))
PLAYER_X=10
PLAYER_Y=5
SCORE=0
DIFFICULTY=1

# Assets
PLAYER_CHAR="◈"
COIN_CHAR="●"
# Skinny scanlines using background colors
SCAN1="\e[48;5;232m"
SCAN2="\e[48;5;234m"
RESET="\e[0m"

trap 'tput cnorm; clear; exit' INT TERM
tput civis

# Generate a static level array for better performance
declare -a TERRAIN
for ((i=0; i<500; i++)); do
    # Creates a rolling hill effect
    TERRAIN[$i]=$(echo "($SCREEN_HEIGHT - 4) - (3 * s($i/5))" | bc -l | cut -d. -f1)
done

draw_game() {
    local VIEWPORT_X=$((PLAYER_X - SCREEN_WIDTH / 2))
    (( VIEWPORT_X < 0 )) && VIEWPORT_X=0
    
    # Move cursor to top-left instead of clearing (reduces flicker)
    tput cup 0 0
    local buffer=""
    
    for ((y=0; y<SCREEN_HEIGHT; y++)); do
        # Toggle background for skinny scanlines
        (( y % 2 == 0 )) && buffer+="$SCAN1" || buffer+="$SCAN2"
        
        for ((x=0; x<SCREEN_WIDTH; x++)); do
            local world_x=$((VIEWPORT_X + x))
            local ground_y=${TERRAIN[$world_x]}
            
            if [[ $world_x -eq $PLAYER_X && $y -eq $PLAYER_Y ]]; then
                buffer+="\e[38;5;82m$PLAYER_CHAR" # Green Player
            elif (( world_x % 15 == 0 && y == ground_y - 2 )); then
                buffer+="\e[38;5;220m$COIN_CHAR" # Gold Coin
                [[ $world_x -eq $PLAYER_X && $y -eq $PLAYER_Y ]] && ((SCORE++))
            elif [[ $y -ge $ground_y ]]; then
                buffer+="\e[38;5;244m█" # Grey Ground
            else
                buffer+=" "
            fi
        done
        buffer+="$RESET\n"
    done
    
    echo -ne "$buffer"
    echo " SCORE: $SCORE | LEVEL: $((1 + SCORE/5)) | [WASD] Move [Q] Quit"
}

# Initial Clear
clear

while true; do
    draw_game

    # Simple Physics: Gravity
    current_ground=${TERRAIN[$PLAYER_X]}
    if (( PLAYER_Y < current_ground - 1 )); then
        ((PLAYER_Y++))
    fi

    # Read input with a slight timeout
    read -rsn3 -t 0.05 key
    
    case "$key" in
        $'\x1b[A'|[wW]) ((PLAYER_Y > 0)) && ((PLAYER_Y -= 2)) ;; # Jump
        $'\x1b[B'|[sS]) ((PLAYER_Y < SCREEN_HEIGHT)) && ((PLAYER_Y++)) ;;
        $'\x1b[C'|[dD]) ((PLAYER_X++)) ;;
        $'\x1b[D'|[aA]) ((PLAYER_X > 0)) && ((PLAYER_X--)) ;;
        [qQ]) break ;;
    esac
done

tput cnorm
clear
