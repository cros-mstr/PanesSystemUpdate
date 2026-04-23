#!/bin/bash
echo "This is a Brave Educational Test App!"
echo "Expect bugs! To update, uninstall then re-install!"

#!/bin/bash

# --- Configuration ---
WIDTH=$(tput cols); HEIGHT=$(tput lines)
GAME_HEIGHT=$((HEIGHT - 10))
PLAYER_X=5; PLAYER_Y=2
SCORE=0; LEVEL=1
WORLD_END=200 

# Assets
SCAN1="\e[48;5;232m"; SCAN2="\e[48;5;233m"
P_CLR="\e[38;5;82m"; C_CLR="\e[38;5;220m"; E_CLR="\e[38;5;196m"
SURFACE_G="\e[38;5;240m▒"; CAVE_G="\e[38;5;52m▒"; RESET="\e[0m"

# State
declare -a TERRAIN; declare -A COINS; declare -a FX; declare -a ENEMIES

save_state=$(stty -g)
trap 'stty "$save_state"; tput cnorm; clear; exit' INT TERM EXIT
stty -echo; tput civis; clear

# --- Optimization: Faster Math ---
get_height() {
    # Using bc less frequently or simple shell math for speed
    if [[ $LEVEL -eq 1 ]]; then
        echo "($GAME_HEIGHT-5) - (2 * s($1/8))" | bc -l | cut -d. -f1
    else
        echo "($GAME_HEIGHT-4) - (($1 % 7) / 2)" | bc -l | cut -d. -f1
    fi
}

init_level() {
    PLAYER_X=5; PLAYER_Y=2
    TERRAIN=(); COINS=(); ENEMIES=(); FX=()
    for ((i=0; i<=WORLD_END; i++)); do
        [[ $i -eq $WORLD_END ]] && TERRAIN[$i]=$((GAME_HEIGHT + 10)) || TERRAIN[$i]=$(get_height $i)
        if [[ $i -gt 20 && $i -lt 195 && $((RANDOM % 100)) -lt 5 ]]; then
            COINS["$i,$((${TERRAIN[$i]} - 2))"]=1
        fi
        if [[ $LEVEL -ge 2 && $i -gt 40 && $i -lt 190 && $((RANDOM % 100)) -lt 3 ]]; then
            ENEMIES+=("$i|$((${TERRAIN[$i]} - 1))|-1")
        fi
    done
}

# --- Giant Text Animation ---
level_pass_anim() {
    local text=(" _     _______     _______ _      " 
                "| |   | ____\ \   / / ____| |     " 
                "| |   |  _|  \ \ / /|  _| | |     " 
                "| |___| |___  \ V / | |___| |___  " 
                "|_____|_____|  \_/  |_____|_____| " 
                " PASSED! GOING DEEPER... ")
    
    for ((offset=WIDTH; offset>-40; offset-=4)); do
        tput cup $((GAME_HEIGHT / 2 - 3)) 0
        for line in "${text[@]}"; do
            printf "%${offset}s%s\e[K\n" "" "$line"
        done
        sleep 0.02
    done
}

play_sound() {
    [[ "$OSTYPE" == "darwin"* ]] && (afplay /System/Library/Sounds/Hero.aiff -r "$1" &) >/dev/null 2>&1
}

is_walkable() {
    local tx=$1; local ty=$2
    [[ $tx -ge $WORLD_END ]] && return 0
    [[ $ty -lt ${TERRAIN[$tx]:-0} ]] && return 0 || return 1
}

update_entities() {
    local n_fx=(); for item in "${FX[@]}"; do
        IFS='|' read -r fx_x fx_y timer <<< "$item"
        (( timer > 0 )) && n_fx+=("$fx_x|$((fx_y - 1))|$((timer - 1))")
    done; FX=("${n_fx[@]}")

    local n_en=()
    for e in "${ENEMIES[@]}"; do
        IFS='|' read -r ex ey ed <<< "$e"
        local nx=$((ex + ed))
        is_walkable "$nx" "$ey" && ! is_walkable "$nx" "$((ey + 1))" && ex=$nx || ed=$((ed * -1))
        if [[ $ex -eq $PLAYER_X ]]; then
            if [[ $PLAYER_Y -lt $ey ]]; then 
                FX+=("$ex|$ey|2"); SCORE+=5; play_sound 1.5; COINS["$ex,$ey"]=1; continue
            elif [[ $PLAYER_Y -eq $ey ]]; then
                stty "$save_state"; tput cnorm; clear; echo "GAME OVER"; exit
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
            
            # Use flags for faster drawing
            local char=" "
            if [[ $wx -eq $PLAYER_X && $y -eq $PLAYER_Y ]]; then char="${P_CLR}◈"
            elif [[ ${COINS["$wx,$y"]} -eq 1 ]]; then char="${C_CLR}●"
            elif [[ $y -ge $gy ]]; then char="$G_CHAR"
            else
                for e in "${ENEMIES[@]}"; do
                    IFS='|' read -r ex ey ed <<< "$e"
                    [[ $ex -eq $wx && $ey -eq $y ]] && { char="${E_CLR}▼"; break; }
                done
                for f in "${FX[@]}"; do
                    IFS='|' read -r fx_x fx_y timer <<< "$f"
                    [[ $fx_x -eq $wx && $fx_y -eq $y ]] && { char="\e[38;5;226m+1"; break; }
                done
            fi
            buffer+="$char"
        done
        buffer+="$RESET\n"
    done
    echo -ne "$buffer"
    echo -e "\e[1m LVL: $LEVEL | SCORE: $SCORE | POS: $PLAYER_X / $WORLD_END \e[0m"
}

# --- Loop ---
init_level
while true; do
    draw_frame
    update_entities
    is_walkable "$PLAYER_X" "$((PLAYER_Y + 1))" && ((PLAYER_Y++))

    if [[ $PLAYER_Y -ge $((GAME_HEIGHT - 1)) ]]; then
        level_pass_anim
        LEVEL=$((LEVEL + 1)); init_level; continue
    fi

    if [[ ${COINS["$PLAYER_X,$PLAYER_Y"]} -eq 1 ]]; then
        unset "COINS[$PLAYER_X,$PLAYER_Y]"; SCORE+=1; play_sound 2.0; FX+=("$PLAYER_X|$PLAYER_Y|2")
    fi

    # Faster refresh rate (0.02 instead of 0.04)
    read -rsn1 -t 0.02 key
    [[ $key == $'\x1b' ]] && { read -rsn2 -t 0.001 r; key+="$r"; }
    case "$key" in
        $'\x1b[A'|[wW]) is_walkable "$PLAYER_X" "$((PLAYER_Y - 3))" && ((PLAYER_Y -= 3)) ;;
        $'\x1b[C'|[dD]) is_walkable "$((PLAYER_X + 1))" "$PLAYER_Y" && ((PLAYER_X++)) ;;
        $'\x1b[D'|[aA]) [[ $PLAYER_X -gt 0 ]] && is_walkable "$((PLAYER_X - 1))" "$PLAYER_Y" && ((PLAYER_X--)) ;;
        [qQ]) break ;;
    esac
done
