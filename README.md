# Tricks and Scripts

Personal crap.


```sh
cd $HOME/code
```

```sh
git clone git@github.com:esamattis/dotfiles.git
```

Add to `~/.zshrc`

```sh
source "$HOME/code/dotfiles/init.zsh"
```

## Tools from homebrew

```
brew install git-delta
brew install jq
brew install fzf
brew install htop
brew install pngpaste
brew install smudge/smudge/nightlight
brew install gh
brew install pure
brew install neovim
brew install fd
brew install sevenzip
brew install yazi
```


## Allow SSH access

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/esamattis/dotfiles/refs/heads/main/allow-github-keys.sh)"
```

## Home homegit

```
git clone --separate-git-dir=~/.homegit git@github.com:esamattis/homegit.git ~
```

## Git config

.gitconfig.local

```
[user]
  name = Esa-Matti Suuronen
  email = code@esamatti.fi
  #signingkey = /Users/esamatti/.ssh/id_ed25519.pub
[github]
  user = esamattis
```
