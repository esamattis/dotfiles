# dotfiles

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

Credits https://news.ycombinator.com/item?id=11071754

```
git clone --separate-git-dir=$HOME/.homegit git@github.com:esamattis/homegit.git $HOME/.homegit-tmp
,config config status.showUntrackedFiles no
rm -rf .homegit-tmp
,config st
```

## Git config

.gitconfig.local

```
[user]
  name = Esa-Matti Suuronen
  email = code@esamatti.fi
  #signingkey = ~/.ssh/id_ed25519.pub
#[commit]
#  gpgsign = true
[github]
  user = esamattis
```


## Aerospace

https://github.com/FelixKratz/JankyBorders

```
brew tap FelixKratz/formulae
brew install borders
```

https://nikitabobko.github.io/AeroSpace

```
brew install --cask nikitabobko/tap/aerospace
```
