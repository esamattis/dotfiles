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

exec $HOME/code/dotfiles/bin/zed-agent-clipboard --paste-all
