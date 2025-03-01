
# https://stackoverflow.com/a/18814147/153718
export DOTFILES="${0:A:h}"


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

autoload -Uz compinit promptinit
compinit
promptinit




compdef 'eval "$(rt --zsh-complete $LBUFFER $RBUFFER)"' rt

export RTN_RUNNERS=scripts:node_modules/.bin
compdef 'eval "$(rt --runners-env RTN_RUNNERS --zsh-complete $LBUFFER $RBUFFER)"' rtn
rtn() {
    rt --runners-env RTN_RUNNERS $@
}


# not in path on macos?
export PATH=/usr/local/bin:$PATH

export PATH="${DOTFILES}/bin:$PATH"

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



export EDITOR=vim-clean

# Not enough contrast in the default colors
zstyle ':prompt:pure:prompt:success' color cyan
zstyle ':prompt:pure:prompt:error' color red




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

# fzf keybindings install:
source <(fzf --zsh)


if [ -f ~/code/fzf-tab/fzf-tab.plugin.zsh ]; then
    source ~/code/fzf-tab/fzf-tab.plugin.zsh
else
    echo "fzf-tab plugin not found" >&2
fi

# Remove CWD dirs from fzf-z
# https://github.com/andrewferrier/fzf-z#sources-of-information
export FZFZ_SUBDIR_LIMIT=0

export FZF_DEFAULT_COMMAND=esamatti-fzf-find
export FZF_CTRL_T_COMMAND=esamatti-fzf-find

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --no-color
'

zstyle ':fzf-tab:*' fzf-flags --bind "tab:toggle,enter:accept"

export EDITOR=nvim
alias vim=nvim
alias vi=nvim

# Zed autocomplete with args does not work. This is a workaround.
compdef _gnu_generic zed




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

# Create a pull request against the current branch.
# Generates a new local branch automatically, pushes it to github and open PR creation form.
# Requires the GH CLI.
gh-pr() {
	if [ "$(git status --porcelain)" != "" ]; then
		echo "Not clean git"
		return 1
	fi

    local username="$(git config --global github.user || whoami)"
	local title=

    local commit_message="$(git log --format=%B -n 1 HEAD)"

	if [ "${1}" = "" ]; then
        echo
        echo "Leave it empty to use \"$commit_message\""
        echo
		read "title?PR Title> "
	else
		title="${1}"
	fi

    if [ "$title" = "" ]; then
        title="$commit_message"
    fi

    # Generate safe branch name
	local branch="$(echo "$title" | head -c50 | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]-')"

    local default_base="$(git rev-parse --abbrev-ref HEAD)"
    local base=

    echo
    git branch --sort=committerdate | tail -n 10
    echo
    echo "Some recently used branches 👆"

    echo
    echo "Target remote branch for the PR. Set to empty to use '$default_base'"
    read "base?Branch> "

	if [ "$base" = "" ]; then
		base="$default_base"
	fi

	git switch -c "$username/$branch"

    read "rebase?rebase? y/n> "

    if [ "$rebase" = "y" ]; then
        git rebase -i "$base"
    fi

    # Prefix the remote branch with $(whoami)/ to avoid collisions
	git push origin "$username/$branch:$username/$branch" -u
	gh pr create --title "$title" --base $base --web

    echo "$title" | pbcopy
    echo
    echo "The PR title has been copied to the clipboard"
}

# Jump to a directory in $HOME/code using fzf
p() {
    local dir=$(ls -1 $HOME/code | fzf --header="Jump to project")
    cd "$HOME/code/$dir"
}

__esamatti_yazi() {
    local arg="$1"
    local file=/tmp/zsh-yazi.txt

    while true; do
        rm -f "$file"

        # workaround for https://github.com/sxyazi/yazi/issues/2278#issuecomment-2629352138
        yazi --chooser-file "$file"  < /dev/tty

        if [ ! -f "$file" ]; then
            return
        fi

        local selected="$(cat "$file")"

        if [ "$arg" = "--cd" ]; then
            if [ -d "$selected" ]; then
                cd "$selected"
            else
                cd "$(dirname "$selected")"
            fi
            return
        fi

        BUFFER+="$selected"
        zle reset-prompt
        return
    done
}


zle -N __esamatti_yazi
bindkey ^f __esamatti_yazi

alias cd-yazi='__esamatti_yazi --cd'

cd-fzf() {
    cd "$(fd -t d | fzf)"

}

# auto complete git-commands
zstyle ':completion:*:*:git:*' user-commands ${${(M)${(k)commands}:#git-*}#git-}
