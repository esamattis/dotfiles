#!/bin/sh

set -eu

mkdir -p "$HOME/code"

if [ ! -f install.sh ]; then
    git clone https://github.com/esamattis/dotfiles.git "$HOME/code/dotfiles"
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

# ~/.gitconfig may be managed by other tools (e.g. ansible) so it is only
# created when missing. It includes ~/.gitconfig.local which is for own
# customizations and includes the config from this repo.
repo_gitconfig="$(pwd)/git/gitconfig"

# Migrate the old setup where these were symlinks into this repo
if [ -L "$HOME/.gitconfig" ] && [ "$(readlink "$HOME/.gitconfig")" = "$repo_gitconfig" ]; then
    rm "$HOME/.gitconfig"
fi
if [ -L "$HOME/.gitconfig.local" ] && [ "$(readlink "$HOME/.gitconfig.local")" = "$(pwd)/git/gitconfig.local" ]; then
    rm "$HOME/.gitconfig.local"
fi

if [ ! -e "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    cat > "$HOME/.gitconfig" <<'GITCONFIG'
[include]
    path = ~/.gitconfig.local
GITCONFIG
fi

if [ ! -e "$HOME/.gitconfig.local" ] && [ ! -L "$HOME/.gitconfig.local" ]; then
    cat > "$HOME/.gitconfig.local" <<GITCONFIG
[include]
    path = $repo_gitconfig
[user]
    name = Esa-Matti Suuronen
    email = code@esamatti.fi
    signingkey = ~/.ssh/id_ed25519.pub
[commit]
    gpgsign = true
[gpg]
    format = ssh
[github]
    user = esamattis
# Identity managed outside of dotfiles
[include]
    path = ~/.gitconfig.user
GITCONFIG
elif ! git config --file "$HOME/.gitconfig.local" --get-all include.path 2>/dev/null | grep -q 'dotfiles/git/gitconfig$'; then
    echo "WARNING: $HOME/.gitconfig.local does not include $repo_gitconfig" >&2
fi

zshrc_line='source "$HOME/code/dotfiles/init.zsh"'
zshrc_file="$HOME/.zshrc"

touch "$HOME/.zshrc"
if ! grep -Fqx "$zshrc_line" "$zshrc_file"; then
    printf '%s\n' "$zshrc_line" >> "$zshrc_file"
fi
