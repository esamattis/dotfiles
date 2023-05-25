
# https://stackoverflow.com/a/18814147/153718
_esamatti_dotfiles_dir="${0:A:h}"

_esamatti_dotfiles_init() {
    local os="$(uname)"
    local prefix=

    if [ -x "$(command -v brew)" ]; then
        prefix="$(brew --prefix)"
    fi

    if [ "$os" = "Darwin" ]; then
        fpath+=("${prefix}/share/zsh/site-functions")

        # pure installed using homebrew
        # https://github.com/sindresorhus/pure
        if [ -f "${prefix}/share/zsh/site-functions/prompt_pure_setup"  ]; then
            source  "${prefix}/share/zsh/site-functions/prompt_pure_setup"
        fi
    fi

    if [ "$os" != "Darwin" ] && [ -x "$(command -v keychain)" ]; then
        eval $(keychain --eval)
    fi

}

_esamatti_dotfiles_init

# not in path on macos?
export PATH=/usr/local/bin:$PATH

export PATH="${_esamatti_dotfiles_dir}/bin:$PATH"

# random crap
export PATH=$HOME/bin:$PATH

# pip --user
export PATH=$HOME/.local/bin:$PATH




# Ensure we're in emacs mode
bindkey -e


# Fix home and end
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line


# Bash like autocomplete
setopt noautomenu
setopt nomenucomplete

HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000


# https://github.com/mattjj/my-oh-my-zsh/blob/b1d4bab329456e9a4af49237064d9a3b6566f1b0/history.zsh
# setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
# setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.


# Remove CWD dirs from fzf-z
# https://github.com/andrewferrier/fzf-z#sources-of-information
export FZFZ_SUBDIR_LIMIT=0

export EDITOR=vim-clean

# Not enough contrast in the default colors
zstyle ':prompt:pure:prompt:success' color cyan
zstyle ':prompt:pure:prompt:error' color red

autoload -Uz compinit && compinit



alias keyboard-assistant='sudo open /System/Library/CoreServices/KeyboardSetupAssistant.app/Contents/MacOS/KeyboardSetupAssistant'
alias node_modules_to_path='export PATH="$(pwd)/node_modules/.bin":$PATH'
alias find_old_node_modules='find . -name node_modules -type d -maxdepth 2 -mtime +30'
alias cd-git-root='cd "$(git rev-parse --show-toplevel)"'
alias gbj="git branch-jump"


git-add-to-existing() {

  if [ -d .git ]; then
    echo "Already has a git dir"
    return 1
  fi

  git init
  git remote add origin "$1"
  git fetch origin
  git reset origin/master
  git branch --set-upstream-to origin/master
}

# Fix Home and End for WSL2
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line

# fix delete key
bindkey  "^[[3~"  delete-char

# Fix esc dot for WSL2
bindkey '\e.' insert-last-word

# Repeat the command n times and break on non-zero exit
# usage: repeat_n 3 jest test.ts
repeat_n () {
  local n=$1
  shift

  for i in {1..$n}; do
    $@ || return $?
  done
}

esamattis-fasd-pick-dir() {
  LBUFFER="${LBUFFER}$(fasd -d -l | fzf --keep-right)"
  local ret=$?
  zle reset-prompt
  return $ret
}


zle -N esamattis-fasd-pick-dir
# Use Ctrl+g to pick recently used directory
bindkey '^G' esamattis-fasd-pick-dir

esamatti-fzf-find() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        git ls-files
        return
    fi

    if [ -x "$(command -v fd)" ]; then
        fd --type f --strip-cwd-prefix
        return
    fi

    echo "Not in a git repo" >&2
    return 1
}

export FZF_DEFAULT_COMMAND=esamatti-fzf-find
export FZF_CTRL_T_COMMAND=esamatti-fzf-find

# fzf keybindings install:
# $(brew --prefix)/opt/fzf/install
# https://github.com/junegunn/fzf#using-homebrew
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh



# https://blog.thecodewhisperer.com/permalink/renaming-magically-with-zmv
autoload zmv


ni() {
  # Add packages
  if [ "${1:-}" != "" ]; then
    if [ -f pnpm-lock.yaml ] || [ -f ../../pnpm-lock.yaml ]; then
      pnpm install $@ && pnpm install
    else
      npm install $@
    fi
    return
  fi

  # Prefer installing using the lock file to avoid faker.js like issue.
  # Just call the original command manually when need to update the lock
  if [ -f pnpm-lock.yaml ] || [ -f ../../pnpm-lock.yaml ]; then
    pnpm install --frozen-lockfile
  elif [ -f package-lock.json ] ; then
    npm ci
  else
    npm install
  fi
}

dark()  {
  iterm-profile.py Dark
  export ITERM_PROFILE=Dark
}

light()  {
  iterm-profile.py Light
  export ITERM_PROFILE=Light
}

gwr() {
    cd "$(git rev-parse --show-toplevel)"
    if [ -f .git ]; then
      cd ..
      cd "$(git rev-parse --show-toplevel)"
    fi
}

gwj() {
  local dir=$(
    gwr
    git worktree list  | fzf --header="Jump to git worktree"
  )

  dir=$(echo "$dir" | cut -f 1 -d ' ')

  if [ -d "$dir" ]; then
    cd "$dir"
  fi
}


gwc() {
  git fetch --all
  # local branch=$(git branch -r | cut -d / -f 2- | fzf --header="Checkout git worktree")
  local branch=$(git branch -r --sort=-committerdate --format '%(refname:short)' | head -n 20 | cut -c 8- | fzf --header="Select branch")
  gwr

  local checkout_dir=".worktrees/$branch"

  if [ "${1:-}" != "" ]; then
    checkout_dir=".worktrees/$1"
  fi

  if [ -d "$checkout_dir" ]; then
    cd "$checkout_dir"
    echo "Already checked out"
    return
  fi

  git worktree add "$checkout_dir" "$branch" 
  cd "$checkout_dir"

  if [ -f pnpm-lock.yaml ] && [ ! -d node_modules ]; then
    read -q "REPLY?Install pnpm deps? "
    if [ "$REPLY" = "y" ]; then
      pnpm install
    fi
  fi
}


gwdestroy() {
  cd "$(git rev-parse --show-toplevel)"

  if [ ! -f .git ]; then
    echo "not a git worktree"
    return 1
  fi


  read -q "REPLY?Are you sure? "
  if [ ! "$REPLY" = "y" ]; then
    return 1
  fi


  local worktree_path=$(pwd)

  gwr
  git worktree remove "$worktree_path"
}


