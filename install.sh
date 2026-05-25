#!/bin/sh

set -eu

set -x

if [ ! -f install.sh ]; then
    mkdir -p "$HOME/code"
    git clone git@github.com:esamattis/dotfiles.git
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

git config --global core.hooksPath "$(pwd)/git/hooks"

zshrc_line='source "$HOME/code/dotfiles/init.zsh"'
zshrc_file="$HOME/.zshrc"

if ! grep -Fqx "$zshrc_line" "$zshrc_file"; then
    printf '%s\n' "$zshrc_line" >> "$zshrc_file"
fi
