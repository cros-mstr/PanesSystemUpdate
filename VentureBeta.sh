#!/bin/bash
echo "This is a Brave Educational Test App!"
echo "Expect bugs! To update, uninstall then re-install!"

#!/bin/bash

#!/bin/bash

# --- Configuration ---
WIDTH=$(tput cols); HEIGHT=$(tput lines)
GAME_HEIGHT=$((HEIGHT - 8))
PLAYER_X=10; PLAYER_Y=5
SCORE=0; VIEWPORT_X=0

# Colors
SCAN1="\e[48;5;232m"; SCAN2="\e[48;5;233m"
P_CLR="\e[38;5;82m"; C_CLR="\e[38;5;220m"; RESET="\e[0m"

# --- Initialization & State ---
save_state=$(stty -g)
trap 'stty "$save_state"; tput cnorm; clear; exit' INT TERM EXIT
stty -echo; tput civis; clear

declare -a TERRAIN
declare -A COINS    # Key: "x,y" Value: 1 (exists)
declare -a FX       # Elements: "x|y|timer"

# Generate Level & Random Coins
for ((i=0; i<1000; i++)); do
    TERRAIN[$i]=$(awk -v x="$i" -v h="$GAME_HEIGHT" 'BEGIN {print int((h-5) - (3 * sin(x/10)))}')
    # Randomly place coins (approx 5% chance per X, if space is clear)
    if (( i > 20 && RANDOM % 100 < 5 )); then
        gy=${TERRAIN[$i]}
        COINS["$i,$((gy-2))"]=1
    fi
done

# --- Functions ---
play_sound() {
    [[ "$OSTYPE" == "darwin"* ]] && (afplay /System/Library/Sounds/Tink.aiff -r 1.5 &) >/dev/null 2>&1
}

is_walkable() {
    [[ $2 -lt ${TERRAIN[$1]} ]] && return 0 || return 1
}

update_fx() {
    local new_fx=()
    for item in "${FX[@]}"; do
        IFS='|' read -r fx_x fx_y timer <<< "$item"
        if (( timer > 0 )); then
            # Move up and decrease timer
            new_fx+=("$fx_x|$((fx_y - 1))|$((timer - 1))")
        fi
    done
    FX=("${new_fx[@]}")
}

draw_frame() {
    tput cup 0 0
    local buffer=""
    VIEWPORT_X=$((PLAYER_X - WIDTH / 2))
    (( VIEWPORT_X < 0 )) && VIEWPORT_X=0

    for ((y=0; y<GAME_HEIGHT; y++)); do
        (( y % 2 == 0 )) && buffer+="$SCAN1" || buffer+="$SCAN2"
        for ((x=0; x<WIDTH; x++)); do
            local wx=$((VIEWPORT_X + x))
            local gy=${TERRAIN[$wx]}
            
            # 1. Check for FX (+1 animation)
            local found_fx=0
            for item in "${FX[@]}"; do
                IFS='|' read -r fx_x fx_y timer <<< "$item"
                if [[ $fx_x -eq $wx && $fx_y -eq $y ]]; then
                    # Fade color based on timer (2 = Bright Yellow, 1 = Dim Orange)
                    [[ $timer -eq 2 ]] && buffer+="\e[38;5;226m+1" || buffer+="\e[38;5;208m+1"
                    found_fx=1; break
                fi
            done
            [[ $found_fx -eq 1 ]] && continue

            # 2. Draw Player/Coins/Terrain
            if [[ $wx -eq $PLAYER_X && $y -eq $PLAYER_Y ]]; then
                buffer+="${P_CLR}◈" 
            elif [[ ${COINS["$wx,$y"]} -eq 1 ]]; then
                buffer+="${C_CLR}●"
            elif [[ $y -ge $gy ]]; then
                buffer+="\e[38;5;240m▒"
            else
                buffer+=" "
            fi
        done
        buffer+="$RESET\n"
    done
    
    echo -ne "$buffer"
    echo -e "\e[1m SCORE: $SCORE | POS: $PLAYER_X \e[0m"
    echo " [W] Jump | [A][D] Move | Coins disappear on collect with +1 FX!"
}

# --- Main Loop ---
while true; do
    draw_frame
    update_fx

    # Gravity
    is_walkable "$PLAYER_X" "$((PLAYER_Y + 1))" && ((PLAYER_Y++))

    # Collection Logic (Touch)
    if [[ ${COINS["$PLAYER_X,$PLAYER_Y"]} -eq 1 ]]; then
        unset "COINS[$PLAYER_X,$PLAYER_Y]" # Remove coin
        ((SCORE++))
        play_sound
        FX+=("$PLAYER_X|$PLAYER_Y|2") # Add +1 at current pos with 2-frame life
    fi

    read -rsn1 -t 0.04 key
    [[ $key == $'\x1b' ]] && { read -rsn2 -t 0.01 rest; key+="$rest"; }

    case "$key" in
        $'\x1b[A'|[wW]) is_walkable "$PLAYER_X" "$((PLAYER_Y - 3))" && ((PLAYER_Y -= 3)) ;;
        $'\x1b[C'|[dD]) is_walkable "$((PLAYER_X + 1))" "$PLAYER_Y" && ((PLAYER_X++)) ;;
        $'\x1b[D'|[aA]) (( PLAYER_X > 0 )) && is_walkable "$((PLAYER_X - 1))" "$PLAYER_Y" && ((PLAYER_X--)) ;;
        [qQ]) break ;;
    esac
done
