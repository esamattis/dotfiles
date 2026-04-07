#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Zed clipboard: Clear
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon ➖
# @raycast.packageName dotfiles

set -eu

rm -f "$TMPDIR/zed-combined-clipboard.txt"
