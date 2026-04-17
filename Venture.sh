#!/bin/bash
PANESType=StatefulApplicationThirdPartySource
PANESSource=ThirdParty
UPDATE_TITLE="pub Venture"
UPDATE_DESC="FPubli Venture"
VERSION=1.01
# Configuration
WIDTH=40
HEIGHT=20
PLAYER_X=20
PLAYER_Y=10
CHAR="■"

# Hide cursor and cleanup on exit
trap 'tput cnorm; clear; exit' INT TERM
tput civis

# Function to draw the UI
draw_frame() {
    # Move to top-left
    tput cup 0 0
    
    for ((y=0; y<HEIGHT; y++)); do
        for ((x=0; x<WIDTH; x++)); do
            # Scanline effect: darken background on even rows
            if (( y % 2 == 0 )); then
                printf "\e[48;5;234m" # Dark grey
            else
                printf "\e[48;5;232m" # Near black
            fi

            if [[ $x -eq $PLAYER_X && $y -eq $PLAYER_Y ]]; then
                printf "\e[38;5;82m$CHAR\e[0m" # Neon green player
            else
                printf " "
            fi
        done
        printf "\e[0m\n"
    done

    # On-screen controls for touch/visual aid
    echo "----------------------------------------"
    echo "  [W/↑] UP    |  Arrow Keys to Move"
    echo "  [A/←] LEFT  |  [S/↓] DOWN | [D/→] RIGHT"
    echo "        Press [Q] to Quit"
    echo "----------------------------------------"
}

# Initial Draw
clear
draw_frame

# Input Loop
while true; do
    # Read 3 characters for arrow keys (Escape sequences)
    read -rsn3 key 2>/dev/null
    
    case "$key" in
        $'\x1b[A'|[wW]) ((PLAYER_Y > 0)) && ((PLAYER_Y--)) ;;     # Up
        $'\x1b[B'|[sS]) ((PLAYER_Y < HEIGHT-1)) && ((PLAYER_Y++)) ;; # Down
        $'\x1b[C'|[dD]) ((PLAYER_X < WIDTH-1)) && ((PLAYER_X++)) ;;  # Right
        $'\x1b[D'|[aA]) ((PLAYER_X > 0)) && ((PLAYER_X--)) ;;     # Left
        [qQ]) break ;;
    esac

    draw_frame
done

# Restore cursor
tput cnorm
clear
