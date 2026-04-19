#!/bin/bash
echo "This is a Brave Educational Test App!"
echo "Expect bugs! To update, uninstall then re-install!"

# --- Screen Setup ---
WIDTH=$(tput cols)
HEIGHT=$(tput lines)
GAME_HEIGHT=$((HEIGHT - 8)) # More room for UI
PLAYER_X=10
PLAYER_Y=5
SCORE=0

# Assets
PLAYER_CHAR="◈"
COIN_CHAR="●"
SCAN1="\e[48;5;232m"
SCAN2="\e[48;5;233m"
RESET="\e[0m"

# Audio logic for macOS
play_sound() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local rate=$(echo "1.0 + ($SCORE * 0.1)" | bc)
        (afplay /System/Library/Sounds/Tink.aiff -r "$rate" &) >/dev/null 2>&1
    else
        printf '\a'
    fi
}

trap 'tput cnorm; clear; exit' INT TERM
tput civis
clear

# --- Level Generation ---
declare -a TERRAIN
for ((i=0; i<(WIDTH + 1000); i++)); do
    # Using awk for smoother hills
    TERRAIN[$i]=$(awk -v x="$i" -v h="$GAME_HEIGHT" 'BEGIN {print int((h-5) - (4 * sin(x/10)))}')
done

# --- Collision Engine ---
# Returns 0 (true) if the position is "Air", 1 (false) if it is "Solid"
is_walkable() {
    local target_x=$1
    local target_y=$2
    local ground_at_x=${TERRAIN[$target_x]}
    
    # If target Y is less than ground Y, it's air.
    if (( target_y < ground_at_x )); then
        return 0 
    fi
    return 1
}

draw_frame() {
    tput cup 0 0
    local buffer=""
    local VIEWPORT_X=$((PLAYER_X - WIDTH / 2))
    (( VIEWPORT_X < 0 )) && VIEWPORT_X=0

    for ((y=0; y<GAME_HEIGHT; y++)); do
        (( y % 2 == 0 )) && buffer+="$SCAN1" || buffer+="$SCAN2"
        for ((x=0; x<WIDTH; x++)); do
            local world_x=$((VIEWPORT_X + x))
            local ground_y=${TERRAIN[$world_x]}
            
            if [[ $world_x -eq $PLAYER_X && $y -eq $PLAYER_Y ]]; then
                buffer+="\e[38;5;82m$PLAYER_CHAR" 
            elif (( world_x % 20 == 0 && y == ground_y - 2 )); then
                buffer+="\e[38;5;220m$COIN_CHAR"
            elif [[ $y -ge $ground_y ]]; then
                buffer+="\e[38;5;240m▒"
            else
                buffer+=" "
            fi
        done
        buffer+="$RESET\n"
    done
    
    echo -ne "$buffer"
    echo -e "\e[1m SCORE: $SCORE | X: $PLAYER_X Y: $PLAYER_Y \e[0m"
    echo " [W] Jump | [A][D] Move | [S] Duck/Fall Fast | [Q] Quit"
}

# --- Main Loop ---
while true; do
    draw_frame

    # 1. Gravity Logic (Only fall if space below is walkable)
    if is_walkable "$PLAYER_X" "$((PLAYER_Y + 1))"; then
        ((PLAYER_Y++))
    fi

    # 2. Check for Coin Pickup
    current_ground=${TERRAIN[$PLAYER_X]}
    if (( PLAYER_X % 20 == 0 && PLAYER_Y == current_ground - 2 )); then
        ((SCORE++))
        play_sound
    fi

    # 3. Input with Collision Checks
    read -rsn3 -t 0.04 key
    case "$key" in
        $'\x1b[A'|[wW]) # Jump: Check 3 spaces up
            if is_walkable "$PLAYER_X" "$((PLAYER_Y - 3))"; then
                ((PLAYER_Y -= 3))
            fi ;;
        $'\x1b[B'|[sS]) # Down: Only move down if it's not the floor
            if is_walkable "$PLAYER_X" "$((PLAYER_Y + 1))"; then
                ((PLAYER_Y++))
            fi ;;
        $'\x1b[C'|[dD]) # Right: Check if the ground at next X is higher than current Y
            if is_walkable "$((PLAYER_X + 1))" "$PLAYER_Y"; then
                ((PLAYER_X++))
            fi ;;
        $'\x1b[D'|[aA]) # Left
            if (( PLAYER_X > 0 )) && is_walkable "$((PLAYER_X - 1))" "$PLAYER_Y"; then
                ((PLAYER_X--))
            fi ;;
        [qQ]) break ;;
    esac
done

tput cnorm
clear
