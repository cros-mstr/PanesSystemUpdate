#!/bin/bash
echo "This is a Brave Educational Test App!"
echo "Expect bugs! To update, uninstall then re-install!"

#!/bin/bash

# --- Setup & Settings ---
WIDTH=$(tput cols); HEIGHT=$(tput lines)
GAME_HEIGHT=$((HEIGHT - 10))
PLAYER_X=5; PLAYER_Y=2
SCORE=0; LEVEL=1
WORLD_END=200 # Level strictly ends here

# Colors & Assets
SCAN1="\e[48;5;232m"; SCAN2="\e[48;5;233m"
P_CLR="\e[38;5;82m"; C_CLR="\e[38;5;220m"; E_CLR="\e[38;5;196m"
SURFACE_G="\e[38;5;240m▒"; CAVE_G="\e[38;5;52m▒"; RESET="\e[0m"

# --- State Arrays ---
declare -a TERRAIN; declare -A COINS; declare -a FX; declare -a ENEMIES

save_state=$(stty -g)
trap 'stty "$save_state"; tput cnorm; clear; exit' INT TERM EXIT
stty -echo; tput civis; clear

init_level() {
    PLAYER_X=5; PLAYER_Y=2
    TERRAIN=(); COINS=(); ENEMIES=(); FX=()
    
    # Generate exactly to WORLD_END
    for ((i=0; i<=WORLD_END; i++)); do
        if [[ $i -eq $WORLD_END ]]; then
            TERRAIN[$i]=$((GAME_HEIGHT + 10)) # The Pit
        else
            if [[ $LEVEL -eq 1 ]]; then
                TERRAIN[$i]=$(awk -v x="$i" -v h="$GAME_HEIGHT" 'BEGIN {print int((h-5) - (2 * sin(x/8)))}')
            else
                # Cave level generation
                TERRAIN[$i]=$(awk -v x="$i" -v h="$GAME_HEIGHT" 'BEGIN {srand(x); print int((h-4) - (rand()*3))}')
            fi
        fi

        # Spawn Coins
        if [[ $i -gt 20 && $i -lt $((WORLD_END - 5)) && $((RANDOM % 100)) -lt 5 ]]; then
            COINS["$i,$((${TERRAIN[$i]} - 2))"]=1
        fi

        # Spawn Enemies (Level 2+)
        if [[ $LEVEL -ge 2 && $i -gt 40 && $i -lt $((WORLD_END - 10)) && $((RANDOM % 100)) -lt 3 ]]; then
            ENEMIES+=("$i|$((${TERRAIN[$i]} - 1))|-1")
        fi
    done
}

play_sound() {
    [[ "$OSTYPE" == "darwin"* ]] && (afplay /System/Library/Sounds/Tink.aiff -r "$1" &) >/dev/null 2>&1
}

is_walkable() {
    local tx=$1; local ty=$2
    [[ $tx -ge $WORLD_END ]] && return 0 # Allow falling into the pit
    [[ $ty -lt ${TERRAIN[$tx]:-0} ]] && return 0 || return 1
}

update_entities() {
    # FX Animation
    local n_fx=(); for item in "${FX[@]}"; do
        IFS='|' read -r fx_x fx_y timer <<< "$item"
        (( timer > 0 )) && n_fx+=("$fx_x|$((fx_y - 1))|$((timer - 1))")
    done; FX=("${n_fx[@]}")

    # Enemy Logic
    local n_en=()
    for e in "${ENEMIES[@]}"; do
        IFS='|' read -r ex ey ed <<< "$e"
        local nx=$((ex + ed))
        if is_walkable "$nx" "$ey" && ! is_walkable "$nx" "$((ey + 1))"; then
            ex=$nx
        else
            ed=$((ed * -1))
        fi
        
        if [[ $ex -eq $PLAYER_X ]]; then
            if [[ $PLAYER_Y -lt $ey ]]; then # Stomp
                FX+=("$ex|$ey|2"); SCORE+=5; play_sound 0.6
                COINS["$ex,$ey"]=1; continue
            elif [[ $PLAYER_Y -eq $ey ]]; then
                stty "$save_state"; tput cnorm; clear
                echo "GAME OVER - Level $LEVEL - Score $SCORE"; exit
            fi
        fi
        n_en+=("$ex|$ey|$ed")
    done; ENEMIES=("${n_en[@]}")
}

draw_frame() {
    tput cup 0 0
    local buffer=""; local VX=$((PLAYER_X - WIDTH / 2))
    (( VX < 0 )) && VX=0
    [[ $LEVEL -eq 1 ]] && G_CHAR="$SURFACE_G" || G_CHAR="$CAVE_G"

    for ((y=0; y<GAME_HEIGHT; y++)); do
        (( y % 2 == 0 )) && buffer+="$SCAN1" || buffer+="$SCAN2"
        for ((x=0; x<WIDTH; x++)); do
            local wx=$((VX + x)); local gy=${TERRAIN[$wx]:-99}
            local found=0
            
            # Check FX
            for item in "${FX[@]}"; do
                IFS='|' read -r fx_x fx_y timer <<< "$item"
                if [[ $fx_x -eq $wx && $fx_y -eq $y ]]; then buffer+="\e[38;5;226m+1"; found=1; break; fi
            done; [[ $found -eq 1 ]] && continue
            
            if [[ $wx -eq $PLAYER_X && $y -eq $PLAYER_Y ]]; then buffer+="${P_CLR}◈"
            elif [[ ${COINS["$wx,$y"]} -eq 1 ]]; then buffer+="${C_CLR}●"
            else
                local is_e=0; for e in "${ENEMIES[@]}"; do
                    IFS='|' read -r ex ey ed <<< "$e"; if [[ $ex -eq $wx && $ey -eq $y ]]; then buffer+="${E_CLR}▼"; is_e=1; break; fi
                done
                if [[ $is_e -eq 1 ]]; then :; elif [[ $y -ge $gy ]]; then buffer+="$G_CHAR"; else buffer+=" "; fi
            fi
        done; buffer+="$RESET\n"
    done
    echo -ne "$buffer"
    echo -e "\e[1m LEVEL: $LEVEL | SCORE: $SCORE | POS: $PLAYER_X / $WORLD_END \e[0m"
}

# --- Main Game Loop ---
init_level
while true; do
    draw_frame
    update_entities
    
    # Gravity & Pit Transition
    is_walkable "$PLAYER_X" "$((PLAYER_Y + 1))" && ((PLAYER_Y++))
    
    if [[ $PLAYER_Y -ge $((GAME_HEIGHT - 1)) ]]; then
        LEVEL=$((LEVEL + 1))
        # Visual feedback for falling
        clear; echo "FALLING DEEPER..."; sleep 1
        init_level
        continue
    fi

    # Coin Collection
    if [[ ${COINS["$PLAYER_X,$PLAYER_Y"]} -eq 1 ]]; then
        unset "COINS[$PLAYER_X,$PLAYER_Y]"; SCORE+=1; play_sound 1.2; FX+=("$PLAYER_X|$PLAYER_Y|2")
    fi

    read -rsn1 -t 0.04 key
    [[ $key == $'\x1b' ]] && { read -rsn2 -t 0.01 r; key+="$r"; }
    case "$key" in
        $'\x1b[A'|[wW]) is_walkable "$PLAYER_X" "$((PLAYER_Y - 3))" && ((PLAYER_Y -= 3)) ;;
        $'\x1b[C'|[dD]) is_walkable "$((PLAYER_X + 1))" "$PLAYER_Y" && ((PLAYER_X++)) ;;
        $'\x1b[D'|[aA]) [[ $PLAYER_X -gt 0 ]] && is_walkable "$((PLAYER_X - 1))" "$PLAYER_Y" && ((PLAYER_X--)) ;;
        [qQ]) break ;;
    esac
done
