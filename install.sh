#!/bin/sh

set -eu

set -x

rm -f "$HOME/.vimrc"
ln -sf "$(pwd)/vim/vimrc" "$HOME/.vimrc"

rm -f "$HOME/.config/nvim/init.vim"
mkdir -p "$HOME/.config/nvim"
ln -sf "$(pwd)/vim/vimrc" "$HOME/.config/nvim/init.vim"

ln -sf "$(pwd)/git/gitconfig" "$HOME/.gitconfig"

