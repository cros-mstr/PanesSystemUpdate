#!/bin/bash
PANESType=StatefulApplicationThirdPartySource
PANESSource=ThirdParty
UPDATE_TITLE="pub Venture"
UPDATE_DESC="FPubli Venture"
VERSION=1.01
# Configuration
#!/bin/bash

# --- Configuration ---
SCREEN_WIDTH=$(tput cols)
[[ $SCREEN_WIDTH -gt 100 ]] && SCREEN_WIDTH=100
SCREEN_HEIGHT=18
WORLD_WIDTH=1000
PLAYER_X=5
PLAYER_Y=10
VIEWPORT_X=0
SCORE=0
DIFFICULTY=1
LEVEL_SEED=$RANDOM

# Assets
PLAYER_CHAR="◈"
COIN_CHAR="●"
SCANLINE_COLOR="\e[38;5;232m" # Very dark grey
COIN_COLOR="\e[38;5;220m"     # Gold
PLAYER_COLOR="\e[38;5;82m"    # Lime Green
RESET="\e[0m"

# Clean up terminal
trap 'tput cnorm; clear; exit' INT TERM
tput civis

# Function to get "Terrain Height" at a specific X (Procedural)
get_terrain() {
    local x=$1
    # Use sine-like waves mixed with pseudo-randomness based on DIFFICULTY
    # This creates the "Random Level" feel
    echo "scale=0; $SCREEN_HEIGHT - 3 - (4 * s($x/5)) - (($x * $DIFFICULTY % 7) / 2)" | bc -l | cut -d. -f1
}

# Function to check for coins at a position
has_coin() {
    local x=$1
    local y=$2
    # Coins appear every 8-12 units if Y is above ground
    if (( x % 10 == 0 && y == 8 )); then return 0; fi
    return 1
}

draw_game() {
    VIEWPORT_X=$((PLAYER_X - SCREEN_WIDTH / 2))
    (( VIEWPORT_X < 0 )) && VIEWPORT_X=0
    
    tput cup 0 0
    local buffer=""
    
    for ((y=0; y<SCREEN_HEIGHT; y++)); do
        # "Skinny" Scanline logic: Every even row gets a slightly darker tint
        if (( y % 2 == 0 )); then buffer+="\e[48;5;233m"; else buffer+="\e[48;5;234m"; fi
        
        for ((x=0; x<SCREEN_WIDTH; x++)); do
            local world_x=$((VIEWPORT_X + x))
            local ground_y=$(get_terrain $world_x)
            
            if [[ $world_x -eq $PLAYER_X && $y -eq $PLAYER_Y ]]; then
                buffer+="${PLAYER_COLOR}${PLAYER_CHAR}\e[39m"
                # Simple Collision/Coin Pick-up
                if has_coin $world_x $y; then ((SCORE++)); fi
            elif has_coin $world_x $y; then
                buffer+="${COIN_COLOR}${COIN_CHAR}\e[39m"
            elif [[ $y -ge $ground_y ]]; then
                buffer+="\e[38;5;240m█" # Solid ground
            else
                buffer+=" "
            fi
        done
        buffer+="$RESET\n"
    done
    
    # Increase difficulty based on score
    DIFFICULTY=$(( 1 + SCORE / 5 ))
    
    echo -ne "$buffer"
    echo -e "\e[1m SCORE: $SCORE | LEVEL: $DIFFICULTY \e[0m"
    echo " [W/A/S/D] to move | Coins give you points | Difficulty increases every 5 coins!"
}

clear
while true; do
    draw_game

    # Adjust sleep time based on difficulty (Game gets faster)
    SLEEP_TIME=$(echo "scale=2; 0.1 - ($DIFFICULTY * 0.005)" | bc -l)
    [[ $(echo "$SLEEP_TIME < 0.02" | bc -l) -eq 1 ]] && SLEEP_TIME=0.02

    read -rsn3 -t $SLEEP_TIME key
    
    case "$key" in
        $'\x1b[A'|[wW]) ((PLAYER_Y > 0)) && ((PLAYER_Y--)) ;;
        $'\x1b[B'|[sS]) ((PLAYER_Y < SCREEN_HEIGHT - 1)) && ((PLAYER_Y++)) ;;
        $'\x1b[C'|[dD]) ((PLAYER_X++)) ;;
        $'\x1b[D'|[aA]) ((PLAYER_X > 0)) && ((PLAYER_X--)) ;;
        [qQ]) break ;;
    esac
    
    # Gravity (Simple)
    ground_at_pos=$(get_terrain $PLAYER_X)
    if (( PLAYER_Y < ground_at_pos - 1 )); then
        ((PLAYER_Y++))
    fi
done

tput cnorm
clear
