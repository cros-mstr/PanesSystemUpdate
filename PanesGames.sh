#!/bin/bash
# Script to launch a text-based terminal game
PANESType=StatefulApplicationThirdPartySource
PANESSource=FirstParty
UPDATE_TITLE="PanesGames"
UPDATE_DESC="CLI Games for your Panes Install!"
VERSION=1
# Try to find a common ncurses-based game
if command -v ncurses-mines &> /dev/null; then
    GAME_CMD="ncurses-mines"
elif command -v mines &> /dev/null; then # Some systems might just call it 'mines'
    GAME_CMD="mines"
elif command -v ninvaders &> /dev/null; then
    GAME_CMD="ninvaders"
elif command -v nsnake &> /dev/null; then
    GAME_CMD="nsnake"
elif command -v moon-buggy &> /dev/null; then
    GAME_CMD="moon-buggy"
elif command -v robocopy &> /dev/null; then # often part of bsdgames
    GAME_CMD="robocopy" # Example from bsdgames, not actual robocopy
    echo "Note: 'robocopy' is often part of the 'bsdgames' package."
else
    echo "Error: No common terminal game (ncurses-mines, ninvaders, nsnake, moon-buggy, etc.) found."
    echo "You might need to install a package like 'ncurses-mines', 'ninvaders', 'nsnake', or 'bsdgames'."
    exit 1
fi

echo "Launching terminal game: '$GAME_CMD'"
echo "Look for in-game instructions (usually '?' or 'h' for help, 'q' to quit)."

"$GAME_CMD"

echo "Exited game."
exit 0
