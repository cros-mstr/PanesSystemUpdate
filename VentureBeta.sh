#!/bin/bash
echo "This is a Brave Educational Test App!"
echo "Expect bugs! To update, uninstall then re-install!"

# --- Screen Setup ---
# Use the full terminal dimensions
WIDTH=$(tput cols)
HEIGHT=$(tput lines)
# Leave room for the UI at the bottom
GAME_HEIGHT=$((HEIGHT - 4))
PLAYER_X=10
PLAYER_Y=$((GAME_HEIGHT / 2))
SCORE=0
OFFSET=0

# Assets
PLAYER_CHAR="◈"
COIN_CHAR="●"
SCAN1="\e[48;5;232m"
SCAN2="\e[48;5;233m"
RESET="\e[0m"

# Audio logic (macOS built-in)
play_sound() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Plays a subtle system beep on macOS in the background
        (afplay /System/Library/Sounds/Tink.aiff &) >/dev/null 2>&1
    else
        # Standard terminal bell for Linux
        printf '\a'
    fi
}

# Clean up
trap 'tput cnorm; clear; exit' INT TERM
tput civis
clear

# --- Procedural Generation ---
# Pre-generate a very long level to save CPU
declare -a TERRAIN
for ((i=0; i<(WIDTH + 500); i++)); do
    # Create undulating terrain using awk (more portable than bc for some)
    TERRAIN[$i]=$(awk -v x="$i" -v h="$GAME_HEIGHT" 'BEGIN {print int((h-5) - (4 * cos(x/8)))}')
done

draw_frame() {
    # Move cursor to top-left (no flickering)
    tput cup 0 0
    local buffer=""
    
    # Calculate viewport based on player position
    local VIEWPORT_X=$((PLAYER_X - WIDTH / 2))
    (( VIEWPORT_X < 0 )) && VIEWPORT_X=0

    for ((y=0; y<GAME_HEIGHT; y++)); do
        # Skinny Scanlines (Alternating dark rows)
        (( y % 2 == 0 )) && buffer+="$SCAN1" || buffer+="$SCAN2"
        
        for ((x=0; x<WIDTH; x++)); do
            local world_x=$((VIEWPORT_X + x))
            local ground_y=${TERRAIN[$world_x]}
            
            if [[ $world_x -eq $PLAYER_X && $y -eq $PLAYER_Y ]]; then
                buffer+="\e[38;5;82m$PLAYER_CHAR" # Neon Green Player
            elif (( world_x % 20 == 0 && y == ground_y - 2 )); then
                buffer+="\e[38;5;220m$COIN_CHAR" # Gold Coin
            elif [[ $y -ge $ground_y ]]; then
                buffer+="\e[38;5;239m▒" # Dithered Ground
            else
                buffer+=" "
            fi
        done
        buffer+="$RESET\n"
    done
    
    # UI Section
    buffer+="\e[7m SCORE: $SCORE | POS: $PLAYER_X | [W/A/S/D] MOVE | [Q] QUIT \e[0m\n"
    # On-screen Arrows for Touch/Visual
    buffer+="    [W] ↑    \n"
    buffer+="[A] ←   [D] →\n"
    buffer+="    [S] ↓    "
    
    echo -ne "$buffer"
}

# --- Game Loop ---
while true; do
    draw_frame

    # Gravity Logic
    current_ground=${TERRAIN[$PLAYER_X]}
    if (( PLAYER_Y < current_ground - 1 )); then
        ((PLAYER_Y++))
    fi

    # Check for Coin Pickup
    if (( PLAYER_X % 20 == 0 && PLAYER_Y == current_ground - 2 )); then
        ((SCORE++))
        play_sound
    fi

    # Input (Ultra-short timeout for smoothness)
    read -rsn3 -t 0.03 key
    
    case "$key" in
        $'\x1b[A'|[wW]) ((PLAYER_Y > 0)) && ((PLAYER_Y -= 3)) ;; # Higher Jump
        $'\x1b[B'|[sS]) ((PLAYER_Y < GAME_HEIGHT)) && ((PLAYER_Y++)) ;;
        $'\x1b[C'|[dD]) ((PLAYER_X++)) ;;
        $'\x1b[D'|[aA]) ((PLAYER_X > 0)) && ((PLAYER_X--)) ;;
        [qQ]) break ;;
    esac
done

tput cnorm
clear
