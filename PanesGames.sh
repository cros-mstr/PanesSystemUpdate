#!/bin/bash
# Script to launch a text-based terminal game with auto-install option

# --- Script Metadata ---
PANESType=StatefulApplicationThirdPartySource
PANESSource=FirstParty
UPDATE_TITLE="PanesGames v2"
UPDATE_DESC="CLI Games for your Panes Install! As of v2, Panes will automatically find and install the games for you if you do not have them already installed."
VERSION=2

# --- Function to install games ---
install_game() {
    local game_package="$1"
    echo "The game '$game_package' is not installed."
    read -p "Do you want to install '$game_package' now? (y/n) " -n 1 -r
    echo # Move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Check for package managers in common order
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y "$game_package"
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y "$game_package"
        elif command -v yum &> /dev/null; then
            sudo yum install -y "$game_package"
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm "$game_package"
        else
            echo "Error: No supported package manager (apt, dnf, yum, pacman) found."
            echo "Please install '$game_package' manually."
            exit 1
        fi
    else
        echo "Exiting without installing."
        exit 1
    fi
}

# --- Game selection logic ---
GAME_CMD=""

# Try to find and install a common ncurses-based game
if ! command -v ncurses-mines &> /dev/null; then
    install_game "ncurses-mines"
fi
GAME_CMD="ncurses-mines"

# If ncurses-mines fails to install or is not preferred, check for other games
if [[ -z "$GAME_CMD" || ! command -v "$GAME_CMD" &> /dev/null ]]; then
    if ! command -v ninvaders &> /dev/null; then
        install_game "ninvaders"
    fi
    GAME_CMD="ninvaders"
fi

if [[ -z "$GAME_CMD" || ! command -v "$GAME_CMD" &> /dev/null ]]; then
    if ! command -v nsnake &> /dev/null; then
        install_game "nsnake"
    fi
    GAME_CMD="nsnake"
fi

if [[ -z "$GAME_CMD" || ! command -v "$GAME_CMD" &> /dev/null ]]; then
    if ! command -v moon-buggy &> /dev/null; then
        install_game "moon-buggy"
    fi
    GAME_CMD="moon-buggy"
fi

# Fallback to bsdgames, which contains several simple games
if [[ -z "$GAME_CMD" || ! command -v "$GAME_CMD" &> /dev/null ]]; then
    if ! command -v bsdgames &> /dev/null; then
        install_game "bsdgames"
    fi
    # Use 'gomoku' as an example from bsdgames
    if command -v gomoku &> /dev/null; then
        GAME_CMD="gomoku"
    fi
fi

# --- Final check and execution ---
if [[ -z "$GAME_CMD" ]]; then
    echo "Error: No suitable terminal game was found or installed."
    echo "You might need to manually install a package like 'ncurses-mines', 'ninvaders', 'nsnake', or 'bsdgames'."
    exit 1
fi

echo "Launching terminal game: '$GAME_CMD'"
echo "Look for in-game instructions (usually '?' or 'h' for help, 'q' to quit)."

"$GAME_CMD"

echo "Exited game."
exit 0
