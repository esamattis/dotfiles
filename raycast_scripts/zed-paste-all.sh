#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Zed clipboard: Paste All
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon ➕
# @raycast.packageName dotfiles

set -eu

FILE="$TMPDIR/zed-combined-clipboard.txt"

if [ ! -f "$FILE" ]; then
  echo "File not found: $FILE"
  exit 1
fi

# Save current clipboard contents
old_clipboard=$(pbpaste)

# Copy file contents to clipboard
pbcopy < "$FILE"

# Simulate Cmd+V paste via AppleScript
osascript -e 'tell application "System Events" to keystroke "v" using command down'

# Give a moment for the paste to complete, then restore old clipboard
sleep 0.5
echo "$old_clipboard" | pbcopy

echo "Pasted contents from zed-combined-copy.txt"
