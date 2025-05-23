#!/bin/bash
# Script to launch a text-based document editor (nano by default)

# Check if nano is installed
if command -v nano &> /dev/null; then
    EDITOR_CMD="nano"
elif command -v vim &> /dev/null; then
    EDITOR_CMD="vim"
elif command -v vi &> /dev/null; then
    EDITOR_CMD="vi"
else
    echo "Error: No suitable text editor (nano, vim, or vi) found."
    echo "Please install one of these to use this script."
    exit 1
fi

echo "Launching '$EDITOR_CMD' to edit a document."
echo "Press Ctrl+X to exit (for nano), or :q (for vi/vim) to quit."

# If a filename is provided as an argument, open that file.
# Otherwise, open the editor without a specific file.
if [ -n "$1" ]; then
    "$EDITOR_CMD" "$1"
else
    "$EDITOR_CMD"
fi

echo "Exited text editor."
exit 0
