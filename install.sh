#!/bin/sh

set -eu

mkdir -p "$HOME/code"

if [ ! -f install.sh ]; then
    git clone git@github.com:esamattis/dotfiles.git "$HOME/code/dotfiles"
    cd "$HOME/code/dotfiles"
fi

if [ ! -d "$HOME/code/fzf-tab" ]; then
    git clone https://github.com/Aloxaf/fzf-tab.git "$HOME/code/fzf-tab"
fi

rm -f "$HOME/.vimrc"
ln -sf "$(pwd)/vim/vimrc" "$HOME/.vimrc"

rm -f "$HOME/.config/nvim/init.vim"
mkdir -p "$HOME/.config/nvim"
ln -sf "$(pwd)/vim/vimrc" "$HOME/.config/nvim/init.vim"

ln -sf "$(pwd)/git/gitconfig" "$HOME/.gitconfig"

if [ ! -f "$HOME/.gitconfig.local" ]; then
    ln -sf "$(pwd)/git/gitconfig.local" "$HOME/.gitconfig.local"
fi

zshrc_line='source "$HOME/code/dotfiles/init.zsh"'
zshrc_file="$HOME/.zshrc"

touch "$HOME/.zshrc"
if ! grep -Fqx "$zshrc_line" "$zshrc_file"; then
    printf '%s\n' "$zshrc_line" >> "$zshrc_file"
fi
